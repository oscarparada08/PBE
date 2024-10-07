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
    reader = MFRC522::Reader.new

    # Busca nuevas tarjetas
    unless reader.picc_is_new_card_present
      puts "No card present. Please try again.".red
      sleep(1)
      next  # Salta a la siguiente iteración si no hay tarjeta presente
    end

    # Lee la tarjeta
    unless reader.picc_read_card_serial
      puts "Failed to read card. Please try again.".red
      sleep(1)
      next  # Salta a la siguiente iteración si no se puede leer la tarjeta
    end

    # Convertimos el UID a formato hexadecimal
    uid_hex = reader.uid.map { |byte| byte.to_s(16).upcase.rjust(2, '0') }.join
    puts "\t YOUR UID IS:"
    puts "\t" + ">>>>>>>>>>".green
    puts "\t" + uid_hex.green  # Mostramos el UID en verde
    puts "\t" + ">>>>>>>>>>".green

  rescue StandardError => e
    puts "Error: #{e.message}".red  # Manejo de errores
  end

  # Preguntamos al usuario si quiere escanear otra tarjeta
  print "\t SCAN AGAIN? (y/n): "
  
  # Leemos la entrada del usuario y la convertimos a minúsculas
  opc = gets.chomp.downcase
end

