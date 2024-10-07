require 'mfrc522'
require 'pi_piper'

# Configuración de pines
RST_PIN = 22  # Pin para RST del MFRC522
SDA_PIN = 24  # Pin para SDA del MFRC522

# Inicializa el lector
reader = MFRC522.new(spi: 0, cs: SDA_PIN, reset: RST_PIN)

# Bucle principal
loop do
  puts "Por favor, acerque su tarjeta al lector..."

  # Intenta leer el UID de la tarjeta
  uid = reader.read_uid
  if uid
    puts "UID de la tarjeta: #{uid.join(', ')}"
  else
    puts "No se detectó ninguna tarjeta."
  end

  # Pregunta al usuario si quiere volver a escanear
  print "¿Desea escanear de nuevo? (s/n): "
  respuesta = gets.chomp.downcase

  # Salir del bucle si la respuesta no es "s"
  break unless respuesta == 's'
end

puts "Programa terminado."
