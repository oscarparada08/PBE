require 'spi'
require 'pi_piper'

class MFRC522
  def initialize(cs_pin:, rst_pin:)
    # Configurar SPI en Raspberry Pi
    @spi = SPI.new(device: '/dev/spidev0.0', mode: 0, speed: 1_000_000)

    # Configurar pines GPIO para Chip Select y Reset
    @cs_pin = PiPiper::Pin.new(pin: cs_pin, direction: :out)
    @rst_pin = PiPiper::Pin.new(pin: rst_pin, direction: :out)

    reset_device
  end

  def reset_device
    @rst_pin.on # Poner el pin RST en alto
    sleep 0.1
    @rst_pin.off # Reiniciar el dispositivo
    sleep 0.1
    @rst_pin.on
  end

  def read_uid
    # Activar Chip Select
    @cs_pin.off

    # Enviar comando de lectura de tarjeta
    response = @spi.xfer([0x93, 0x20]) # Comando para leer tarjeta RFID

    # Desactivar Chip Select
    @cs_pin.on

    # Procesar la respuesta para obtener el UID
    uid = response[1..4] # Extraer los bytes correspondientes al UID
    uid.map { |byte| byte.to_s(16).rjust(2, '0') }.join(':').upcase
  end
end

# Pines GPIO de la Raspberry Pi para el lector MFRC522
CS_PIN = 25  # GPIO para Chip Select (SDA en el MFRC522)
RST_PIN = 22 # GPIO para Reset (RST en el MFRC522)

# Crear una instancia del lector RFID
lector = MFRC522.new(cs_pin: CS_PIN, rst_pin: RST_PIN)

puts "Lector RFID activado. Coloca una tarjeta para leer el UID..."

# Bucle para leer tarjetas RFID
loop do
  uid = lector.read_uid
  unless uid.empty?
    puts "UID de la tarjeta: #{uid}"
  end
  sleep 1
end


  sleep 1
end
