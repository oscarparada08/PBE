require 'spi'
require 'pi_piper'

class MFRC522
  REQIDL = 0x26
  OK = 0

  def initialize(spi_id: 0, sck:, miso:, mosi:, cs:, rst:)
    # Configura el dispositivo SPI en '/dev/spidev0.0'
    @spi = SPI.new(device: '/dev/spidev0.0', mode: 0, speed: 1_000_000) 
    @cs_pin = cs
    @rst_pin = rst

    # Configura los pines usando PiPiper
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).on # Chip Select como salida y en estado alto
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).on # Reset como salida y en estado alto
    init
  end

  def init
    # Reinicia el lector MFRC522
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).off
    sleep(0.05)
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).on
  end

  def request(mode)
    # Envía la solicitud para detectar una tarjeta
    cs_pin = PiPiper::Pin.new(pin: @cs_pin, direction: :out)
    cs_pin.off # Activa el CS (Chip Select)
    
    # Transferencia SPI para enviar el comando y recibir la respuesta
    response = @spi.xfer([mode])
    
    cs_pin.on # Desactiva el CS
    [OK, response]
  end

  def select_tag_sn
    # Selecciona la tarjeta y devuelve su UID
    cs_pin = PiPiper::Pin.new(pin: @cs_pin, direction: :out)
    cs_pin.off
    
    # Comando para seleccionar tarjeta y obtener UID
    response = @spi.xfer([0x93, 0x20]) # Comando de selección de tarjeta (ejemplo)
    
    cs_pin.on
    uid = response[1..4] # Extrae el UID de la respuesta (primeros 4 bytes)
    [OK, uid]
  end
end

# Pines GPIO de la Raspberry Pi para el lector MFRC522
CS_PIN = 25  # Sustituir por el pin GPIO correcto
RST_PIN = 22 # Sustituir por el pin GPIO correcto

# Crear instancia del lector RFID
lector = MFRC522.new(spi_id: 0, sck: 2, miso: 4, mosi: 3, cs: CS_PIN, rst: RST_PIN)

puts "Lector activo...\n"

loop do
  lector.init
  stat, tag_type = lector.request(MFRC522::REQIDL)
  
  if stat == MFRC522::OK
    stat, uid = lector.select_tag_sn
    
    if stat == MFRC522::OK
      identificador = uid.reverse.inject(0) { |acc, byte| (acc << 8) | byte } # Convierte bytes a entero
      puts "UID: #{identificador}"
    end
  end

  sleep 1
end
