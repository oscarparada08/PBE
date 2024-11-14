require 'gtk3'
require_relative 'reader_thread'
require_relative 'puzzle1'

class MainWindow < Gtk::Window
  def initialize
    super
    set_title('Lectura de targeta UPC')
    set_default_size(400, 200)

    # Carregar els estils CSS
    provider = Gtk::CssProvider.new
    provider.load(data: File.read('styles.css'))
    style_context.add_provider(provider, Gtk::StyleProvider::PRIORITY_USER)

    # Contenidor vertical
    vbox = Gtk::Box.new(:vertical, 10)
    add(vbox)

    # Etiqueta per demanar login
    @label = Gtk::Label.new('Escanegi la targeta per obtenir el UID')
    vbox.pack_start(@label, expand: false, fill: false, padding: 5)

    # Camp de text per mostrar el UID
    @textview = Gtk::TextView.new
    @textview.set_editable(false)
    vbox.pack_start(@textview, expand: true, fill: true, padding: 5)

    # Botó per esborrar el UID
    @clear_button = Gtk::Button.new(label: 'Clear')
    @clear_button.signal_connect('clicked') { clear_uid }
    vbox.pack_start(@clear_button, expand: false, fill: false, padding: 5)

    # Comença el thread per llegir el UID
    start_reader_thread

    show_all
  end

  def start_reader_thread
    ReaderThread.new(self)
  end

  def update_uid(uid)
    # Actualitza el text del TextView amb el UID llegit
    buffer = @textview.buffer
    buffer.text = "UID llegit: #{uid}"
  end

  def clear_uid
    # Esborra el text del TextView
    @textview.buffer.text = ''
  end
end

# Inicialitza l'aplicació
app = Gtk::Application.new('com.exemple.lectura_targeta', :flags_none)
app.signal_connect('activate') do |application|
  win = MainWindow.new
  win.application = application
  win.show_all
end

app.run
