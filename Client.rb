require "gtk3"
 require_relative 'rfid'
 require "net/http"
 require "json"
 require 'i2c/drivers/lcd'
 class LCD
  def initialize(address)
    @display = I2C::Drivers::LCD::Display.new('/dev/i2c-1', address, rows=20, 
cols=4)
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
      @display.text(" Demasiadas lineas", 1)
      @display.text(" Maximo de lineas:4", 2)
    else
      lines.each_with_index do |line, i|
        if line.length > 20
          line = "#{line[0...17]}..."
        end
        @display.text(line, i)
      end
    end
  end
 end
 class RfidWindow < Gtk::Window
  def initialize
    super("Lectura de tarjeta")
    set_default_size(400, 150)
    set_window_position(:center)
    signal_connect("destroy") { Gtk.main_quit }
    box = Gtk::Box.new(:vertical, 7)
    add(box)
    @label = Gtk::Label.new("Acerque la tarjeta", :expand => true)
    @label.override_background_color(0, Gdk::RGBA.new(0, 0, 1, 1))
    box.pack_start(@label, expand: true, fill: true, padding: 0)
 Downloaded by Óscar Parada Fernández (oscar.parada@estudiantat.upc.edu)
 lOMoARcPSD|17346660
    button = Gtk::Button.new(:label => "Clear")
    button.set_size_request(100, 50)
    box.pack_start(button, expand: false, fill: false, padding: 0)
    button.signal_connect("clicked") do
      @label.set_text("Acerque la tarjeta")
      @label.override_background_color(0, Gdk::RGBA.new(0, 0, 1, 1))
    end
    @lcd = LCD.new(0x27) # Inicializar la pantalla LCD
    @lcd.show_message("Acerque la tarjeta")
    @reading_enabled = true # Habilitar la lectura de la tarjeta por defecto
    show_all
    iniciar_lectura_tarjeta # Iniciar la lectura de la tarjeta automáticamente
  end
  
  def update_label(uid)
    # Enviar el UID al servidor para autenticación
    respuesta = enviar_consulta("http://192.168.79.114:3000/authenticate?
 uid=#{uid}")
    # Parsear la respuesta JSON
    begin
      respuesta_json = JSON.parse(respuesta)
    rescue JSON::ParserError => e
      mostrar_error("Error al parsear la respuesta del servidor.")
      return
    end
    if respuesta_json["error"]
      mostrar_error(respuesta_json["error"])
    else
      # Actualizar el contenido del LCD con el nombre del estudiante autenticado
      @lcd.show_string("Bienvenido, #{respuesta_json["name"]}")
      # Mostrar el nombre del estudiante autenticado en la etiqueta
      @label.set_text("Bienvenido, #{respuesta_json["name"]}")
      @label.override_background_color(0, Gdk::RGBA.new(1, 0, 0, 1))
      # Solicitar al usuario que ingrese la consulta
      solicitar_consulta
    end
  end
  def enviar_consulta(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
 Downloaded by Óscar Parada Fernández (oscar.parada@estudiantat.upc.edu)
 lOMoARcPSD|17346660
    response.body
  end
  def mostrar_error(error)
    # Mostrar el mensaje de error en la etiqueta
    @label.set_text("Error: #{error}")
    @label.override_background_color(0, Gdk::RGBA.new(1, 0, 0, 1))
    
    # Mostrar el mensaje de error en el LCD
    @lcd.show_string("Error: #{error}")
  end
  def solicitar_consulta
    dialog = Gtk::Dialog.new(
      title: "Consulta",
      parent: self,
      flags: Gtk::DialogFlags::MODAL,
      buttons: [[Gtk::Stock::OK, Gtk::ResponseType::ACCEPT], 
[Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]]
    )
    content_area = dialog.child
    content_area.add(Gtk::Label.new("Ingrese la consulta en el formato: table?
 constraint&constraint&..."))
    entry = Gtk::Entry.new
    content_area.add(entry)
    entry.set_text("tasks")
    dialog.show_all
    response = dialog.run
    if response == Gtk::ResponseType::ACCEPT
      consulta = entry.text
      ejecutar_consulta(consulta)
    end
    dialog.destroy
  end
  def ejecutar_consulta(consulta)
    # Enviar la consulta al servidor y recibir la respuesta
    url = "http://192.168.79.114:3000/query?#{consulta}"
    respuesta = enviar_consulta(url)
    # Mostrar la respuesta en el LCD
    @lcd.show_string("Respuesta: #{respuesta}")
    # Mostrar la respuesta en la etiqueta
    @label.set_text("Respuesta: #{respuesta}")
 Downloaded by Óscar Parada Fernández (oscar.parada@estudiantat.upc.edu)
 lOMoARcPSD|17346660
    @label.override_background_color(0, Gdk::RGBA.new(1, 1, 0, 1))
  end
  def iniciar_lectura_tarjeta
    Thread.new {
      rf = Rfid.new
      loop do
        if @reading_enabled
          uid = rf.read_uid
          update_label(uid)
        end
        sleep(0.1)
      end
    }
  end
 end
 win = RfidWindow.new
 Gtk.main
