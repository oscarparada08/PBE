require 'spi'
require 'pi_piper'

class MFRC522
  PICC_REQIDL = 0x26
  CMD_AUTHENT = 0x60
  CMD_READ = 0x30
  OK = 0

  def initialize(cs_pin:, rst_pin:)
    @spi = SPI.new(device: '/dev/spidev0.0', mode: 0, speed: 1_000_000) # Configura SPI
    @cs_pin = cs_pin
    @rst_pin = rst_pin

    # Configura pines usando PiPiper
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).on # Chip Select como salida y en estado alto
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).on # RST como salida y en estado alto

    init
  end

  def init
    # Resetea el lector MFRC522
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).off
    sleep(0.05)
    PiPiper::Pin.new(pin: @rst_pin, direction: :out).on
    # Aquí puedes agregar más comandos de inicialización si es necesario
  end

  def request(tag_type)
    # Enviar solicitud para detectar tarjetas
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).off # Activa el CS (Chip Select)
    response = @spi.write([PICC_REQIDL, tag_type])
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).on # Desactiva el CS
    response
  end

  def read_uid
    # Aquí se implementaría la lógica para leer el UID de la tarjeta
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).off
    # Leer y procesar la UID de la tarjeta RFID
    response = @spi.write([CMD_READ])
    PiPiper::Pin.new(pin: @cs_pin, direction: :out).on
    response
  end
end

# Pines GPIO usados para CS y RST
CS_PIN = 25  # Sustituir por el pin GPIO correspondiente
RST_PIN = 22 # Sustituir por el pin GPIO correspondiente

rfid = MFRC522.new(cs_pin: CS_PIN, rst_pin: RST_PIN)

puts "Escaneando tarjetas RFID..."

loop do
  response = rfid.request(MFRC522::PICC_REQIDL)

  if response[0] == MFRC522::OK
    uid = rfid.read_uid
    puts "Tarjeta detectada, UID: #{uid}"
  else
    puts "No se ha detectado ninguna tarjeta."
  end

  sleep 1
end
