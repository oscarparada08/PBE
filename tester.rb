require 'gtk3'
require 'mfrc522'
require 'thread'

class RfidApp
  def initialize
    @reader = MFRC522.new

    # Crear la ventana principal
    @window = Gtk::Window.new
    @window.set_title("Lectura RFID")
    @window.set_default_size(400, 200)

    # Crear una etiqueta (Label) para mostrar el UID
    @label = Gtk::Label.new("Por favor, acerque la tarjeta al lector")

    # Crear un botón para limpiar la etiqueta
    @clear_button = Gtk::Button.new(label: "Limpiar")
    @clear_button.signal_connect("clicked") { clear_uid }

    # Empaquetar los widgets en un contenedor
    box = Gtk::Box.new(:vertical, 10)
    box.pack_start(@label, :expand => true, :fill => true, :padding => 10)
    box.pack_start(@clear_button, :expand => false, :fill => true, :padding => 10)

    # Asignar el contenedor a la ventana
    @window.add(box)

    # Conectar la señal de cierre de la ventana
    @window.signal_connect("destroy") { Gtk.main_quit }

    # Mostrar todos los elementos de la ventana
    @window.show_all

    # Iniciar un hilo para leer el UID sin bloquear la interfaz
    @read_thread = Thread.new { read_rfid }
  end

  # Método para leer el UID RFID (bloqueante, por eso se ejecuta en un hilo)
  def read_rfid
    while true
      uid = read_uid
      update_label(uid) if uid
      sleep(1) # Evitar que el hilo consuma demasiado CPU
    end
  end

  # Método para leer el UID del lector RFID
  def read_uid
    quedat = 1
    while quedat == 1
      begin
        @reader.picc_request(MFRC522::PICC_REQA)  # Establecer comunicación con el lector
        uid_dec, _ = @reader.picc_select          # Intentar leer el UID
      rescue CommunicationError
        # No hay tarjeta detectada o ha expirado el tiempo de espera
      else
        # Si se captura el UID, salir del bucle
        return uid_dec.map { |x| x.to_s(16) }.join.upcase
      end
    end
    nil
  end

  # Método para actualizar la etiqueta con el UID leído
  def update_label(uid)
    Gtk.main_queue do
      @label.text = "UID: #{uid}"
    end
  end

  # Método para limpiar la etiqueta
  def clear_uid
    Gtk.main_queue do
      @label.text = "Por favor, acerque la tarjeta al lector"
    end
  end
end

# Iniciar la aplicación GTK
app = RfidApp.new
Gtk.main

