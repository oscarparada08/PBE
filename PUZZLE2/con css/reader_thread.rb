require 'gtk3'
require_relative 'PUZZLE1.rb' # Incluye la clase Rfid

class ReaderThread
  def initialize(window)
    @window = window
    @rfid_reader = Rfid.new

    # Inicia el hilo del lector RFID
    Thread.new do
      loop do
        uid = @rfid_reader.read_uid
        # Actualiza la GUI de manera segura en el hilo principal
        GLib::Idle.add do
          @window.update_uid(uid)
          false # Asegura que el bloque no se repita
        end
      end
    end
  end
end

