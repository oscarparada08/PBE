# Este script utiliza un lector RFID MFRC522 para leer el UID de tarjetas RFID
# Requiere una Raspberry Pi y módulos adicionales para GPIO y control de colores en terminal.


require 'pi_piper'  # Biblioteca para controlar los pines GPIO en la Raspberry Pi
require 'colorize'   # Biblioteca para agregar color al texto en la terminal
require 'mfrc522'    # Biblioteca para interactuar con el lector RFID MFRC522

class RfidRc522
  def scan_uid
    reader = MFRC522::Reader.new
    uid = reader.read_uid  # Leer UID de la tarjeta RFID

    # Si no se lee ningún UID, lanzar una excepción
    raise "No UID read" if uid.nil?

    uid_hex = uid.map { |byte| byte.to_s(16).upcase }.join
    return uid_hex
  end
end

def clear_screen
  system('clear')
end

opc = ""

while opc != "n"
  clear_screen

  puts "\t" + "<<<<<<<<<<<<".red
  puts "\t" + "    SCAN   ".yellow
  puts "\t" + "    YOUR   ".yellow
  puts "\t" + "    PASS   ".yellow
  puts "\t" + "<<<<<<<<<<<<".red

  begin
    rf = RfidRc522.new
    uid = rf.scan_uid  # Escanea y obtiene el UID

    puts "\t YOUR UID IS:"
    puts "\t" + ">>>>>>>>>>".green
    puts "\t" + uid.strip.sub(/^0x/i, "").green  # Muestra el UID en verde
    puts "\t" + ">>>>>>>>>>".green

  rescue => e
    # Captura cualquier error y muestra un mensaje
    puts "Error: #{e.message}".red
    sleep(2)  # Pausa para que el usuario lea el mensaje de error
  ensure
    opc = "n"  # Inicializa la opción como 'n'
    print "\t SCAN AGAIN? (y/n): "
    opc = gets.chomp.downcase
    RPi::GPIO.clean_up  # Limpia los pines GPIO
  end
end

