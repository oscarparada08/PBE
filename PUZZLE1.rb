# Este script utiliza un lector RFID MFRC522 para leer el UID de tarjetas RFID
# Asegúrate de tener las bibliotecas necesarias instaladas.

require 'rpi_gpio'  # Biblioteca para controlar los pines GPIO en la Raspberry Pi
require 'mfrc522'   # Biblioteca para interactuar con el lector RFID MFRC522

# Definimos una clase que se encargará de manejar el lector RFID
class RfidRc522
  def initialize
    @reader = MFRC522::Reader.new  # Creamos una nueva instancia del lector RFID
  end

  # Método para escanear y leer el UID de la tarjeta
  def scan_uid
    uid = @reader.read_uid
    return uid if uid
    nil
  end
end

# Método que limpia la pantalla del terminal
def clear_screen
  system('clear')
end

# Bucle principal
rfid_reader = RfidRc522.new
loop do
  clear_screen
  puts "Coloca tu tarjeta RFID cerca del lector..."
  
  # Escanear el UID de la tarjeta
  uid = rfid_reader.scan_uid

  if uid
    puts "UID de la tarjeta: #{uid.join('-')}"  # Muestra el UID en la terminal
  else
    puts "No se detectó ninguna tarjeta."
  end
  
  sleep(1)  # Espera 1 segundo antes de volver a escanear
end
