require 'gtk3'
require_relative 'PUZZLE1'  # Cargar la biblioteca del puzzle 1
require 'thread'

class RfidApp
  def initialize
    # Crear la ventana principal
    @window = Gtk::Window.new
    @window.set_title("Lectura de targeta RFID")
    @window.set_default_size(300, 200)
    @window.signal_connect("destroy") { Gtk.main_quit }

    # Crear el Label para mostrar el texto de la UID
    @label = Gtk::Label.new("Si us plau, introdueixi la seva targeta sobre el lector.")
    
    # Crear el botón de "Clear"
    @button_clear = Gtk::Button.new(label: "Clear")
    @button_clear.signal_connect("clicked") { clear_uid }

    # Crear el diseño (box) para la ventana
    vbox = Gtk::Box.new(:vertical, 10)
    vbox.pack_start(@label, :expand => true, :fill => true, :padding => 10)
    vbox.pack_start(@button_clear, :expand => false, :fill => false, :padding => 10)

    @window.add(vbox)
    @window.show_all

    # Inicializar el lector RFID
    @rfid_reader = Rfid.new
  end

  def start_reading_uid
    # Crear un hilo separado para leer el UID de la tarjeta
    Thread.new do
      begin
        uid = @rfid_reader.read_uid  # Llamar al método de lectura de UID de la biblioteca puzzle1
        Gtk.main_add { @label.text = "UID: #{uid}" }
      rescue => e
        Gtk.main_add { @label.text = "Error: #{e.message}" }
      end
    end
  end

  def clear_uid
    # Actualizar el Label para limpiar la información
    @label.text = "Si us plau, introdueixi la seva targeta sobre el lector."
  end

  def run
    # Iniciar el proceso de lectura
    start_reading_uid

    # Iniciar la GUI de Gtk
    Gtk.main
  end
end

# Crear una nueva instancia de la aplicación y arrancarla
app = RfidApp.new
app.run
