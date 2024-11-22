require 'gtk3'
require_relative 'reader_thread' # Solo importa la clase del hilo

class Window < Gtk::Window
  def initialize
    super
    set_title 'RFID Reader'
    set_border_width 10
    set_size_request 500, 200

    # Cargar estilos desde style.css
    load_css('style.css')

    signal_connect('destroy') { Gtk.main_quit }

    # Contenedor principal
    vbox = Gtk::Box.new(:vertical, 10)
    add(vbox)

    # Etiqueta inicial
    @label = Gtk::Label.new("Por favor, acerque su tarjeta")
    @label.set_name('label') # Asignar el ID CSS
    vbox.pack_start(@label, expand: true, fill: true, padding: 10)

    # Botón de limpiar
    button = Gtk::Button.new(label: 'Clear')
    button.set_name('button') # Asignar el ID CSS
    button.signal_connect('clicked') { on_clear_clicked }
    vbox.pack_start(button, expand: false, fill: false, padding: 10)
  end

  def on_clear_clicked
    @label.set_text("Por favor, acerque su tarjeta")
    @label.set_name('label') # Restaurar el estilo CSS original
  end

  def update_uid(uid)
    @label.set_text("UID: #{uid}")
    @label.set_name('label red') # Cambiar el estilo al de alerta
  end

  private

  def load_css(file)
    provider = Gtk::CssProvider.new
    provider.load(path: file)
    Gtk::StyleContext.add_provider_for_screen(
      Gdk::Screen.default,
      provider,
      Gtk::StyleProvider::PRIORITY_USER
    )
  end
end

# Crear ventana principal y ejecutar el hilo del lector RFID
win = Window.new
win.show_all

# Iniciar el hilo del lector RFID
ReaderThread.new(win)

# Iniciar el bucle principal de GTK
Gtk.main
