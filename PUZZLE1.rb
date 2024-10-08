require 'pi_piper'   # Biblioteca para acceder a GPIO
require 'spi'        # Biblioteca para SPI
require 'mfrc522'    # Biblioteca para el lector RFID

class RFIDReader
  SPI_BUS = 0            # Configura el bus SPI (0 o 1)
  SPI_CHIP_SELECT = 0    # Pin de selección del chip

  def initialize
    # Inicializa SPI
    @spi = SPI::Bus.open(SPI_BUS, SPI_CHIP_SELECT)
    # Inicializa el lector MFRC522
    @mfrc522 = MFRC522.new(spi: @spi)
  end

  def read_uid
    loop do
      # Intenta leer la UID de una tarjeta
      uid = @mfrc522.read_uid
      if uid
        puts "UID de la tarjeta: #{uid.join(", ")}"
        break
      else
        puts "Esperando tarjeta..."
        sleep 1 # Espera 1 segundo antes de volver a intentar
      end
    end
  end

  def authenticate(sector, key)
    # Autenticación para un sector específico
    if @mfrc522.authenticate(sector, key)
      puts "Autenticado correctamente para el sector #{sector}"
      true
    else
      puts "Error de autenticación en el sector #{sector}"
      false
    end
  end

  def read_block(sector, block)
    # Leer datos de un bloque específico de una tarjeta
    if authenticate(sector, MFRC522::KEY_A)
      data = @mfrc522.read_block(sector, block)
      puts "Datos del bloque #{block}: #{data.join(", ")}"
    end
  end

  def write_block(sector, block, data)
    # Escribir datos en un bloque específico de una tarjeta
    if authenticate(sector, MFRC522::KEY_A)
      if @mfrc522.write_block(sector, block, data)
        puts "Datos escritos en el bloque #{block}."
      else
        puts "Error al escribir en el bloque #{block}."
      end
    end
  end

  def cleanup
    # Cierra el bus SPI al terminar
    @spi.close
  end
end

# Uso del lector RFID
reader = RFIDReader.new

begin
  reader.read_uid

  # Ejemplo de lectura y escritura en bloques
  reader.read_block(1, 0) # Lee bloque 0 del sector 1
  reader.write_block(1, 0, [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]) # Escribe en bloque 0 del sector 1
ensure
  reader.cleanup  # Asegúrate de cerrar el SPI al terminar
end
