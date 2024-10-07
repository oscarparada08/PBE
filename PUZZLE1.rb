require 'gpio'
require 'mrfc522'
require 'colorize'

# Inicializar el lector RC522
reader = MRFC522.new(
  sda: 8,   # Pin SDA
  reset: 7  # Pin Reset
)

# Función para escanear el RFID
def scan_rfid(reader)
  puts "Acerque su tarjeta RFID..."
  uid = reader.read_uid
  if uid
    puts "¡Tarjeta detectada! UID: #{uid.join('-').colorize(:green)}"
    uid.join('-')  # Devuelve el UID como una cadena
  else
    puts "No se detectó ninguna tarjeta.".colorize(:red)
    nil
  end
end

loop do
  # Escanear la tarjeta
  scanned_uid = scan_rfid(reader)

  # Preguntar si quiere volver a escanear
  if scanned_uid
    print "¿Desea escanear otra tarjeta? (s/n): "
    respuesta = gets.chomp.downcase
    break unless respuesta == 's'
  else
    puts "Intente nuevamente.".colorize(:yellow)
  end
end

puts "Proceso finalizado.".colorize(:blue)
