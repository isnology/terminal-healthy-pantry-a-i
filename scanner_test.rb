#require 'rubyserial'

#serialport = Serial.new '/dev/tty.GlennGS7e-BlueScanner'
#serialport = Serial.new '/dev/tty.GlennGS7e-BlueScanner', 9600, 8, :even

#system("clear")

#while true
#   str = serialport.read(13)
#   puts str
# end

require 'rubygems'
require 'websocket-client-simple'
require 'mail'
require 'curses'

include Curses


Curses.start_color
# Determines the colors in the attron() in put_str()
Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'localhost',
            :user_name            => 'grmarks@gmail.com',
            :password             => 'samba001',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }



Mail.defaults do
  delivery_method :smtp, options
end

ws = WebSocket::Client::Simple.connect 'ws://192.168.1.6:9999/'

ws.on :message do |msg|
  puts msg.data

  # Mail.deliver do
  #   to       'grmarks@gmail.com,'
  #   from     'gspantrymanagment@gmail.com'
  #   subject  'Test Email from G&S Dietry Pantry A.I.'
  #   body     "This is the barcode: #{msg.data}"
  # end
  
end

ws.on :open do
  ws.send 'connected!'
end

# ws.on :close do |e|
#   p e
#   exit 1
# end

# ws.on :error do |e|
#   p e
# end

Curses.init_screen
Curses.clear
Curses.setpos(0, 1)
Curses.attron(color_pair(COLOR_GREEN)|A_NORMAL) { Curses.addstr('Testing typed and barcode input: ') }
Curses.refresh
sleep(5)
Curses.close_screen

system("clear")
puts
puts "Scanning mode"
puts
puts "Enter 90 to return to menu"
loop do
  str = STDIN.gets.strip
  break if str.to_i == 90
  if str[0, 5] == 'Demo '
    puts 'ignore ' + str
  else  
    ws.send str
  end   
end

