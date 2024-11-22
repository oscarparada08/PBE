require "gtk3"
require "thread"
require_relative "PUZZLE1.rb"

class Window < Gtk::Window
  def initialize
    super
    set_title 'rfid_gtk.rb' 
    set_border_width 10
    set_size_request 500, 200

    # Load CSS
    load_css("style.css")

    signal_connect("destroy") do
      Gtk.main_quit
      @thread.kill if @thread
    end

    @hbox = Gtk::Box.new(:vertical, 6)
    add(@hbox)

    # Label
    @label = Gtk::Label.new("Please, login with your university card")
    @label.set_name("label") # Apply CSS ID
    @hbox.pack_start(@label)

    # Button
    @button = Gtk::Button.new(label: 'Clear')
    @button.set_name("button") # Apply CSS ID
    @button.signal_connect('clicked') { on_clear_clicked }
    @hbox.pack_start(@button)
  end

  def on_clear_clicked
    @label.set_markup("Please, login with your university card")
    @label.set_name("label") # Reset CSS class
    @thread.kill if @thread
    rfid
  end

  def rfid
    @rfid = Rfid.new
    @thread = Thread.new do
      uid = @rfid.read_uid
      GLib::Idle.add do
        @label.set_markup("uid: #{uid}")
        @label.set_name("label red") # Change CSS class
        false
      end
    end
  end

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

win = Window.new
win.show_all
win.rfid
Gtk.main
