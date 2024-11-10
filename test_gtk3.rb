require 'gtk3'

window = Gtk::Window.new
window.set_title("GTK3 Test")
window.set_default_size(200, 100)
window.signal_connect("destroy") { Gtk.main_quit }

window.show_all
Gtk.main
