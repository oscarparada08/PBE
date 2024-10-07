require 'pigpio'

# Configura los pines
SS_PIN = 8   # CE0
RST_PIN = 25

# Inicia la biblioteca pigpio
$gpio = Pigpio::Gpio.new

# Configura los pines
$gpio.set_mode(SS_PIN, Pigpio::OUTPUT)
$gpio.set_mode(RST_PIN, Pigpio::OUTPUT)

# Función para escribir un valor en el registro
def rc522_write(register, value)
  $gpio.write(RST_PIN, 0)  # Activar el módulo
  # Aquí se realizaría la comunicación SPI para escribir el valor
  $gpio.write(RST_PIN, 1)  # Desactivar el módulo
end

# Función para leer un valor del registro
def rc522_read(register)
  $gpio.write(RST_PIN, 0)  # Activar el módulo
  # Aquí se realizaría la comunicación SPI para leer el valor
  $gpio.write(RST_PIN, 1)  # Desactivar el módulo
  return 0  # Devuelve un valor de prueba
end

# Inicializa el módulo RC522
def init_rc522
  rc522_write(0x01, 0x0F)  # Activar el módulo
  rc522_write(0x2A, 0x8D)  # Configurar el modo de espera
end

# Función para detectar la tarjeta
def detect_card
  # Implementa la lógica para detectar la tarjeta
  return true  # Para pruebas, devuelve verdadero
end

# Función para leer el ID de la tarjeta
def read_card_id
  return "123456"  # Para pruebas, devuelve un ID fijo
end

# Bucle principal
begin
  init_rc522
  puts "Esperando a detectar una tarjeta..."

  loop do
    if detect_card
      puts "Tarjeta detectada!"
      card_id = read_card_id
      puts "ID de la tarjeta: #{card_id}"
      sleep 1  # Espera antes de volver a detectar
    end
    sleep 0.1  # Pequeña pausa para evitar sobrecarga
  end

rescue Interrupt
  puts "Saliendo..."
ensure
  $gpio.write(RST_PIN, 1)  # Asegúrate de desactivar el módulo
  $gpio.stop
end
