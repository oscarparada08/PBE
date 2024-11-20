require 'thread'
require_relative 'puzzle1'

class ReaderThread
  def initialize(window)
    @window = window
    @rfid_reader = Rfid.new

    # Inicia el thread de lectura de targeta
    Thread.new do
      loop do
        uid = @rfid_reader.read_uid
        # Executa la funció d'actualització a la finestra principal
        Gtk.queue do
          @window.update_uid(uid)
        end
      end
    end
  end
end
