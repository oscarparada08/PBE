# Este script utiliza un lector RFID MFRC522 para leer el UID de tarjetas RFID
# Requiere una Raspberry Pi y módulos adicionales para GPIO y control de colores en terminal.

requirer'pi_piper' # Biblioteca para controlar los pines GPIO en la Raspberry Pi
require 'colorize'  # Biblioteca para agregar color al texto en la terminal
require 'mfrc522'   # Biblioteca para interactuar con el lector RFID MFRC522

# Definimos una clase que se encargará de manejar el lector RFID
class RfidRc522
  # Método que inicializa el lector, lee el UID de la tarjeta y lo devuelve en formato hexadecimal
  def scan_uid
    # Creamos una nueva instancia del lector RFID
    reader = MFRC522::Reader.new
    
    # Leemos el UID de la tarjeta RFID
    uid = reader.read_uid
    
    # Convertimos el UID a formato hexadecimal en mayúsculas
    uid_hex = uid.map { |byte| byte.to_s(16).upcase }.join
    
    # Retornamos el UID en formato hexadecimal
    return uid_hex
  end
end

# Método que limpia la pantalla del terminal
def clear_screen
  system('clear')
end

# Variable para controlar el ciclo de escaneo
opc = ""

# Bucle que sigue ejecutándose hasta que el usuario elija no escanear más
while opc != "n"
  # Limpiamos la pantalla antes de cada escaneo
  clear_screen
  
  # Mostramos un mensaje con instrucciones para el usuario, con colores
  puts "\t" + "<<<<<<<<<<<<".red
  puts "\t" + "    SCAN   ".yellow
  puts "\t" + "    YOUR   ".yellow
  puts "\t" + "    PASS   ".yellow
  puts "\t" + "<<<<<<<<<<<<".red

  begin
    # Inicializamos el objeto para manejar el lector RFID
    rf = RfidRc522.new
    
    # Escaneamos y obtenemos el UID de la tarjeta
    uid = rf.scan_uid
    
    # Mostramos el UID obtenido en la terminal
    puts "\t YOUR UID IS:"
    puts "\t" + ">>>>>>>>>>".green
    puts "\t" + uid.strip.sub(/^0x/i, "").green  # Eliminamos el prefijo '0x' y mostramos en verde
    puts "\t" + ">>>>>>>>>>".green
  ensure
    # Preguntamos al usuario si quiere escanear otra tarjeta
    opc = "n"  # Inicializamos la opción como 'n' (para evitar que se quede en ciclo infinito)
    print "\t SCAN AGAIN? (y/n): "
    
    # Leemos la entrada del usuario y la convertimos a minúsculas
    opc = gets.chomp.downcase
    
    # Limpiamos los pines GPIO después de cada escaneo
    RPi::GPIO.clean_up
  end
end
