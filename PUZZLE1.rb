require 'spi'
require 'pi_piper'

class MFRC522
  REQIDL = 0x26
  OK = 0

  def initialize(spi_id: 0, sck:, miso:, mosi:, cs:, rst:)
    @spi = SPI.new(device: '/dev/spidev0.0', mode: 0, speed: 1_000_000) # Configura SPI
    @cs_pin = cs
    @rst_pin = rst

    # Configura pines usando PiPiper
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).on # Chip Select como salida
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).on # RST como salida
    init
  end

  def init
    # Inicializa el lector MFRC522
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).off
    sleep(0.05)
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).on
  end

  def request(mode)
    # Envía una solicitud para detectar una tarjeta
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).off # Activa el CS
    response = @spi.write([mode])
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).on # Desactiva el CS
    [OK, response]
  end

  def select_tag_sn
    # Simulación de selección de tarjeta y retorno de UID
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).off
    response = @spi.write([0x93, 0x20]) # Comando para seleccionar tarjeta (ejemplo)
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).on
    uid = response[1..4] # Extracción del UID (4 bytes)
    [OK, uid]
  end
end

lector = MFRC522.new(spi_id: 0, sck: 2, miso: 4, mosi: 3, cs: 1, rst: 0)

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
