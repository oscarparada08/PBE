require 'bundler/setup'
require 'mfrc522'

# Inicializa el lector
r = MFRC522.new

begin
  # Solicita la tarjeta
  r.picc_request(MFRC522::PICC_REQA)
  
  # Selecciona la tarjeta y obtiene el UID
  uid, sak = r.picc_select
  
  # Imprime el UID
  puts "UID de la tarjeta: #{uid}"
rescue CommunicationError => e
  # Manejo de errores en la comunicación
  abort "Error comunicando con la tarjeta: #{e.message}"
end
