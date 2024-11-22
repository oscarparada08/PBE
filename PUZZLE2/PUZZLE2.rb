require "gtk3"
require_relative 'PUZZLE1'
require_relative 'widget_options'

rf = Rfid.new                                                         #Objecte únic RFID

def scan_tag(rf, info_label)
  thr = Thread.new {                                                  #Fil auxiliar bloquejant per llegir RFID
    uid =  rf.read_uid                                                #Lectura 
    puts "Tag detected: " + uid                                       #Mostrem UID per command-prompt.
    info_label.set_markup("uid: " + uid)                              #Mostrem UID per pantalla.
    info_label.override_background_color(0, Gdk::RGBA::new(1,0,0,1))  #Modificació a color vermell de l'etiqueta.
  }
end

#S'ha utilitzat el fitxer widget_options.rb, on tenim, de manera separada, 
#les variables de configuració per una manipulació més senzilla.

window = get_window		#Finestra. Objecte gràfic que encapsula tots els objectes gràfics
grid = get_grid			#Graella. Utilitat per organitzar objectes a la finestra
info_label = get_label		#Etiqueta. Canvia de color i text segons estat de l'aplicació 
clear_button = get_button	#Botó 'clear' (per tornar a llegir RFID)

#Afegir objectes a graella, determinant la seva posició.
grid.attach(info_label,0,0,1,1)
grid.attach(clear_button,0,1,1,1)
window.set_window_position(:center) #Pantalla al centre


clear_button.signal_connect("clicked") do #Actuació en cas de accionar botó
  reset_label(info_label)                 #Reestabliment blau i missatge
  scan_tag(rf, info_label)                
end

window.signal_connect('destroy') { Gtk.main_quit } #Botó de tancament pantalla gràfica, finalitza aplicació


# Run Application
window.add(grid) #Afegim graella amb etiqueta i botó a la finestra visible
window.show_all  #Mostrem elements 
scan_tag(rf, info_label) #Invoquem mètode d'escanejament per primer cop

Gtk.main                  #Bucle gràfic
