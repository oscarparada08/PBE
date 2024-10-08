require 'pi_piper'
require 'colorize'  # Asegúrate de tener la gema colorize instalada
require_relative 'mfrc522' # Asegúrate de que el archivo mfrc522.rb esté en el mismo directorio

class RfidRc522
  def initialize(nrstpd = 24, spd = 8000000, chip = 0, timer = 50)
    chip_option = { 0 => PiPiper::Spi::CHIP_SELECT_0,
                    1 => PiPiper::Spi::CHIP_SELECT_1,
                    2 => PiPiper::Spi::CHIP_SELECT_BOTH,
                    3 => PiPiper::Spi::CHIP_SELECT_NONE }
    @spi_chip = chip_option[chip]
    @spi_spd = spd

    # Power it up
    nrstpd_pin = PiPiper::Pin.new(pin: nrstpd, direction: :out)
    nrstpd_pin.on
    sleep 1.0 / 20.0 # Espera 50ms

    soft_reset # Reinicio de software

    # Configuración de registros
    write_spi(TModeReg, 0x8D) 
    write_spi(TPrescalerReg, 0x3E)
    write_spi(TReloadRegH, (timer >> 8))
    write_spi(TReloadRegL, (timer & 0xFF)) 
    write_spi(TxASKReg, 0x40) 
    write_spi(ModeReg, 0x3D) 

    antenna_on # Activa la antena
  end

  def scan_uid
    uid = []
    begin
      write_spi(CommandReg, PCD_Idle) # Coloca el lector en modo de inactividad
      write_spi(CommIrqReg, 0x7F) # Limpia el registro de interrupciones
      write_spi(ModeReg, 0x3D) # Establece el modo del lector

      # Bucle para buscar tarjetas
      loop do
        uid = read_uid # Reemplaza esto con tu lógica para leer el UID
        break unless uid.empty?
      end

      # Convertimos el UID a formato hexadecimal
      uid_hex = uid.map { |byte| byte.to_s(16).upcase }.join
      return uid_hex
    rescue => e
      puts "Error: #{e.message}".red
      return nil
    end
  end

  def soft_reset
    write_spi(CommandReg, PCD_SoftReset)
    sleep 1.0 / 20.0 # espera 50ms
  end

  def write_spi(reg, values)
    PiPiper::Spi.begin do |spi|
      spi.chip_select_active_low(true)
      spi.bit_order Spi::MSBFIRST
      spi.clock @spi_spd

      spi.chip_select(@spi_chip) do
        spi.write((reg << 1) & 0x7E, *values)
      end
    end
  end

  def read_uid
    # Este es un ejemplo ficticio. Debes implementar la lógica real para leer el UID de la tarjeta.
    [0xDE, 0xAD, 0xBE, 0xEF] # Ejemplo de UID ficticio
  end
  
  def antenna_on
    # Implementa la lógica para activar la antena aquí
    puts "Antenna activated".green
  end
end

# Ejecución del código
rfid_reader = RfidRc522.new

loop do
  puts "Por favor, escanee su tarjeta.".yellow
  uid = rfid_reader.scan_uid
  
  if uid
    puts "UID escaneado: #{uid}".green
  else
    puts "No se pudo escanear un UID.".red
  end

  # Pregunta al usuario si desea escanear nuevamente
  print "¿Desea escanear otra tarjeta? (s/n): "
  opc = gets.chomp.downcase
  
  break if opc != 's'  # Sale del bucle si el usuario no quiere escanear nuevamente
end

puts "Fin del programa.".blue

