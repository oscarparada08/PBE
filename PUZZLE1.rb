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

void loop() {
  // Look for new cards
  if (!mfrc522.PICC_IsNewCardPresent()) {
    return;
  }

  // Read one of the cards
  if (!mfrc522.PICC_ReadCardSerial()) {
    return;
  }

  String RFID = "";

  // Convert from bytes from UID array to String
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    // Workaround: If the byte is less than 0x10, print
    // a `0` before, to output two digits.
    if(mfrc522.uid.uidByte[i] < 0x10) {
      RFID.concat("0");
    }

    RFID.concat(String(mfrc522.uid.uidByte[i], HEX));
  }

  RFID.toUpperCase();

    print RFID;

   Preguntamos al usuario si quiere escanear otra tarjeta
    print "\t SCAN AGAIN? (y/n): "
    
    # Leemos la entrada del usuario y la convertimos a minúsculas
    opc = gets.chomp.downcase

}
  ensure
    # Preguntamos al usuario si quiere escanear otra tarjeta
    print "\t SCAN AGAIN? (y/n): "
    
    # Leemos la entrada del usuario y la convertimos a minúsculas
    opc = gets.chomp.downcase
  end
end

