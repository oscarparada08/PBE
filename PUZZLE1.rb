require 'pi_piper'  # Biblioteca para controlar los pines GPIO en la Raspberry Pi
require 'colorize'   # Biblioteca para agregar color al texto en la terminal
require 'mfrc522'    # Biblioteca para interactuar con el lector RFID MFRC522

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
    # Creamos una nueva instancia del lector RFID
    reader = mfrc522::Reader.new
    
    # Leemos el UID de la tarjeta RFID
    uid = reader.read_uid
    
    # Convertimos el UID a formato hexadecimal en mayúsculas
    uid_hex = uid.map { |byte| byte.to_s(16).upcase }.join

    # Mostramos el UID obtenido en la terminal
    puts "\t YOUR UID IS:"
    puts "\t" + ">>>>>>>>>>".green
    puts "\t" + uid_hex.strip.sub(/^0x/i, "").green  # Eliminamos el prefijo '0x' y mostramos en verde
    puts "\t" + ">>>>>>>>>>".green
  rescue StandardError => e
    puts "Error: #{e.message}".red  # Manejo de errores, en caso de que no se lea el UID
  ensure
    # Preguntamos al usuario si quiere escanear otra tarjeta
    print "\t SCAN AGAIN? (y/n): "
    
    # Leemos la entrada del usuario y la convertimos a minúsculas
    opc = gets.chomp.downcase
  end
end

