require 'pigpio'

# Configuración de pines
SS_PIN = 8   # CE0 (Chip Select)
RST_PIN = 25 # Reset

# Inicializa la biblioteca pigpio
gpio = Pigpio::Gpio.new

# Configura los pines
gpio.set_mode(SS_PIN, Pigpio::OUTPUT)
gpio.set_mode(RST_PIN, Pigpio::OUTPUT)

# Función para escribir en un registro
def rc522_write(gpio, ss_pin, register, value)
  gpio.write(ss_pin, 0)  # Activar el módulo
  # Implementa la comunicación SPI para escribir
  gpio.spi_xfer(0, [register, value])
  gpio.write(ss_pin, 1)  # Desactivar el módulo
end

# Función para leer de un registro
def rc522_read(gpio, ss_pin, register)
  gpio.write(ss_pin, 0)  # Activar el módulo
  response = gpio.spi_xfer(0, [register, 0])  # Enviar el registro y recibir el valor
  gpio.write(ss_pin, 1)  # Desactivar el módulo
  return response[1]     # Devuelve el segundo byte que es el valor leído
end

# Inicializa el RC522
def init_rc522(gpio)
  rc522_write(gpio, SS_PIN, 0x01, 0x0F)  # Activar el módulo
  rc522_write(gpio, SS_PIN, 0x2A, 0x8D)  # Configurar el modo de espera
end

# Función para detectar la tarjeta
def detect_card(gpio)
  # Implementa la lógica para detectar la tarjeta aquí
  true  # Para pruebas, siempre devuelve verdadero
end

# Leer ID de la tarjeta
def read_card_id(gpio)
  "123456"  # Para pruebas, devuelve un ID fijo
end

# Configuración inicial
init_rc522(gpio)

# Bucle principal
begin
  puts "Esperando a detectar una tarjeta..."
  loop do
    if detect_card(gpio)
      puts "Tarjeta detectada!"
      card_id = read_card_id(gpio)
      puts "ID de la tarjeta: #{card_id}"
      sleep 1  # Espera antes de volver a detectar
    end
    sleep 0.1  # Pausa para evitar sobrecarga
  end
rescue Interrupt
  puts "Saliendo..."
ensure
  gpio.write(RST_PIN, 1)  # Asegúrate de desactivar el módulo
  gpio.stop
end
