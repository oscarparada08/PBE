require 'gtk3'
require 'net/http'
require 'json'
require 'i2c/drivers/lcd'

class LCD
  def initialize(address)
    @display = I2C::Drivers::LCD::Display.new('/dev/i2c-1', address, rows = 20, cols = 4)
    @address = address
  end

  def show_message(message)
    @display.clear
    @display.text(message, 0)
  end

  def show_string(string)
    @display.clear
    lines = string.split("\n")
    if lines.length > 4
      @display.text("Demasiadas lineas", 0)
      @display.text("Máximo: 4", 1)
    else
      lines.each_with_index do |line, i|
        line = "#{line[0...17]}..." if line.length > 20
        @display.text(line, i)
      end
    end
  end
end

class RfidWindow < Gtk::Window
  SESSION_TIMEOUT = 120 # Tiempo de inactividad en segundos

  def initialize
    super("Sistema RFID")
    set_default_size(400, 150)
    set_window_position(:center)
    signal_connect("destroy") { Gtk.main_quit }

    # Layout principal
    box = Gtk::Box.new(:vertical, 7)
    add(box)

    @label = Gtk::Label.new("Acerque la tarjeta")
    box.pack_start(@label, expand: true, fill: true, padding: 0)

    button = Gtk::Button.new(label: "Clear")
    box.pack_start(button, expand: false, fill: false, padding: 0)
    button.signal_connect("clicked") { reset_interface }

    @lcd = LCD.new(0x27) # Inicializar la pantalla LCD
    @lcd.show_message("Acerque la tarjeta")

    @reading_enabled = true
    iniciar_temporizador
    iniciar_lectura_tarjeta

    show_all
    aplicar_estilo
  end

  # Resetea la interfaz
  def reset_interface
    @label.set_text("Acerque la tarjeta")
    @label.override_background_color(0, Gdk::RGBA.new(0, 0, 1, 1))
    @lcd.show_message("Acerque la tarjeta")
    reiniciar_temporizador
  end

  # Actualiza la etiqueta y el LCD al leer una tarjeta
  def update_label(uid)
    reiniciar_temporizador
    Thread.new do
      respuesta = enviar_consulta("http://192.168.79.114:3000/authenticate?uid=#{uid}")
      Gtk.queue do
        begin
          respuesta_json = JSON.parse(respuesta)
          if respuesta_json["error"]
            mostrar_error(respuesta_json["error"])
          else
            @lcd.show_string("Bienvenido, #{respuesta_json['name']}")
            @label.set_text("Bienvenido, #{respuesta_json['name']}")
            @label.override_background_color(0, Gdk::RGBA.new(0, 1, 0, 1))
            solicitar_consulta
          end
        rescue JSON::ParserError
          mostrar_error("Respuesta inválida del servidor.")
        end
      end
    end
  end

  # Enviar consulta HTTP
  def enviar_consulta(url)
    begin
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPSuccess
        response.body
      else
        mostrar_error("HTTP Error: #{response.code} #{response.message}")
        nil
      end
    rescue SocketError => e
      mostrar_error("Error de red: #{e.message}")
      nil
    rescue Timeout::Error
      mostrar_error("El servidor no responde.")
      nil
    rescue => e
      mostrar_error("Error inesperado: #{e.message}")
      nil
    end
  end

  # Muestra un mensaje de error
  def mostrar_error(error)
    @label.set_text("Error: #{error}")
    @label.override_background_color(0, Gdk::RGBA.new(1, 0, 0, 1))
    @lcd.show_string("Error: #{error}")
  end

  # Solicita una consulta al usuario
  def solicitar_consulta
    dialog = Gtk::Dialog.new(
      title: "Consulta",
      parent: self,
      flags: Gtk::DialogFlags::MODAL,
      buttons: [[Gtk::Stock::OK, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]]
    )
    content_area = dialog.child
    content_area.add(Gtk::Label.new("Ingrese consulta: table?constraint&..."))
    entry = Gtk::Entry.new
    content_area.add(entry)
    dialog.show_all

    response = dialog.run
    if response == Gtk::ResponseType::ACCEPT
      consulta = entry.text
      ejecutar_consulta(consulta)
    end
    dialog.destroy
  end

  # Ejecuta una consulta al servidor
  def ejecutar_consulta(consulta)
    url = "http://192.168.79.114:3000/query?#{consulta}"
    respuesta = enviar_consulta(url)

    @lcd.show_string("Respuesta: #{respuesta}")
    @label.set_text("Respuesta: #{respuesta}")
    @label.override_background_color(0, Gdk::RGBA.new(1, 1, 0, 1))
  end

  # Hilo de lectura RFID
  def iniciar_lectura_tarjeta
    Thread.new do
      rf = Rfid.new
      loop do
        if @reading_enabled
          begin
            uid = rf.read_uid
            Gtk.queue { update_label(uid) } if uid
          rescue => e
            Gtk.queue { mostrar_error("Error RFID: #{e.message}") }
          end
        end
        sleep(0.5)
      end
    end
  end

  # Temporizador de sesión
  def iniciar_temporizador
    reiniciar_temporizador
  end

  def reiniciar_temporizador
    @timer_thread&.kill
    @timer_thread = Thread.new do
      sleep(SESSION_TIMEOUT)
      Gtk.queue { cerrar_sesion }
    end
  end

  def cerrar_sesion
    @label.set_text("Sesión cerrada por inactividad.")
    @label.override_background_color(0, Gdk::RGBA.new(0, 0, 1, 1))
    @lcd.show_message("Sesión cerrada")
  end

  # Estilo CSS
  def aplicar_estilo
    css_provider = Gtk::CssProvider.new
    css_provider.load_from_path("styles.css")
    Gtk::StyleContext.add_provider_for_screen(
      Gdk::Screen.default,
      css_provider,
      Gtk::StyleProvider::PRIORITY_USER
    )
  end
end

# Archivo CSS: styles.css
# label {
#   font-size: 18px;
#   color: #ffffff;
# }
# button {
#   background-color: #007BFF;
#   color: #ffffff;
#   font-weight: bold;
# }
# window {
#   background-color: #222222;
# }

win = RfidWindow.new
Gtk.main
