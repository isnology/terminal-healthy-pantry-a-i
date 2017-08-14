
class Display

  def initialize(pantry)
    @pantry = pantry
    Curses.start_color
    # Determines the colors in the attron() in put_str()
    Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK) 
    Curses.init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
    Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
    Curses.init_pair(COLOR_BLACK,COLOR_BLACK,COLOR_BLACK)
    Curses.init_pair(COLOR_CYAN,COLOR_CYAN,COLOR_BLACK)
    Curses.init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)
    # NOTE: cyan set and reset in splash_screen()
    
    # bitmaps for large font - sp = space (' '), dt = dot (.), as = ampersand (&) 
    @font = {
      A:  [[' ',' ','1',' ',' '],[' ','1',' ','1',' '],['1',' ',' ',' ','1'],['1','1','1','1','1'],['1',' ',' ',' ','1']],
      D:  [['1','1','1','1',' '],['1',' ',' ',' ','1'],['1',' ',' ',' ','1'],['1',' ',' ',' ','1'],['1','1','1','1',' ']],
      E:  [['1','1','1','1','1'],['1',' ',' ',' ',' '],['1','1','1','1','1'],['1',' ',' ',' ',' '],['1','1','1','1','1']],
      G:  [[' ','1','1','1','1'],['1',' ',' ',' ',' '],['1',' ',' ','1','1'],['1',' ',' ',' ','1'],[' ','1','1','1',' ']],
      I:  [[' ','1','1','1',' '],[' ',' ','1',' ',' '],[' ',' ','1',' ',' '],[' ',' ','1',' ',' '],[' ','1','1','1',' ']],
      N:  [['1',' ',' ',' ','1'],['1','1',' ',' ','1'],['1',' ','1',' ','1'],['1',' ',' ','1','1'],['1',' ',' ',' ','1']],
      P:  [['1','1','1','1',' '],['1',' ',' ',' ','1'],['1','1','1','1',' '],['1',' ',' ',' ',' '],['1',' ',' ',' ',' ']],
      R:  [['1','1','1','1',' '],['1',' ',' ',' ','1'],['1','1','1','1',' '],['1',' ','1',' ',' '],['1',' ',' ','1',' ']],
      S:  [[' ','1','1','1',' '],['1',' ',' ',' ',' '],[' ','1','1','1',' '],[' ',' ',' ',' ','1'],[' ','1','1','1',' ']],
      T:  [['1','1','1','1','1'],[' ',' ','1',' ',' '],[' ',' ','1',' ',' '],[' ',' ','1',' ',' '],[' ',' ','1',' ',' ']],
      Y:  [['1',' ',' ',' ','1'],[' ','1',' ','1',' '],[' ',' ','1',' ',' '],[' ',' ','1',' ',' '],[' ',' ','1',' ',' ']],
      sp: [[' ',' ',' ',' ',' '],[' ',' ',' ',' ',' '],[' ',' ',' ',' ',' '],[' ',' ',' ',' ',' '],[' ',' ',' ',' ',' ']],
      dt: [[' ',' ',' ',' ',' '],[' ',' ',' ',' ',' '],[' ',' ',' ',' ',' '],[' ',' ',' ',' ',' '],[' ','1','1',' ',' ']],
      as: [[' ','1','1','1',' '],['1',' ',' ',' ','1'],[' ','1','1',' ',' '],['1',' ',' ','1',' '],[' ','1','1',' ','1']]
    }
  end  

  def menu_details
    heading(x: 8, y: 31)
    z = 0
    put_str(clr: COLOR_GREEN, str: "#{z += 1}.  Email Details")
    put_str(str: "#{z += 1}.  Shopping Cycle")
    put_str(str: "#{z += 1}.  Stock Adjustment")
    put_str(str: "#{z += 1}.  Scan Mode")
    put_str(str: "#{z += 1}.  Ad Hoc Shopping List")
    put_str(str: '99. Exit')

    set_pos
    Curses.refresh
    Curses.getstr.to_i
  end 
  
  def email_details
    heading(x: 8, y: 31)
    set_pos
    put_str(str: 'Please Enter your email: ', clr: COLOR_GREEN)
    Curses.refresh
    Curses.getstr
  end

  def shopping_cycle_details
    hash = {}
    heading(x: 8, y: 31)
    set_pos
    put_str(str: 'Enter your shopping cycle in days: ', clr: COLOR_GREEN)
    Curses.refresh
    str = Curses.getstr
    hash.store(:cycle, str)
    set_pos
    put_str(str: 'Enter your next shopping date: ', clr: COLOR_GREEN)
    Curses.refresh
    str = Curses.getstr
    date = Date.parse(str)
    hash.store(:date, date)
    hash
  end

  def scan_all_items_in_pantry_details
    system("clear")
    puts
    puts 'Please scan every item currently in pantry'
    puts
    puts "When finished enter '90' to return to menu"
  end  

  def auto_scan_mode_details
    system("clear")
    puts
    puts "Scanning out mode"
    puts
    puts "Enter '90' to return to menu"
  end  
    
  def error_message(option)
    set_pos
    put_str(str: "You entered an invalid option (#{option}).", clr: COLOR_GREEN)
  end

  def pause
    set_pos
    put_str(str: 'Press Enter to continue', clr: COLOR_GREEN)
    Curses.refresh
    Curses.getstr
  end 
  
  def splash_screen
    #speech = Speech.new("YO!", voice: 'en#')
    #speech.speak # invokes espeak
    Curses.init_pair(COLOR_CYAN,COLOR_CYAN,COLOR_CYAN)
    Curses.clear
    Curses.curs_set(0)
    large_char(char: 'G', x: 4, y: 5, clr: COLOR_CYAN)
    large_char(char: 'as')
    large_char(char: 'S')
    large_char(char: 'sp')
    large_char(char: 'D')
    large_char(char: 'I')
    large_char(char: 'E')
    large_char(char: 'T')
    large_char(char: 'R')
    large_char(char: 'Y')
    large_char(char: 'P', x: 13, y: 4)
    large_char(char: 'A')
    large_char(char: 'N')
    large_char(char: 'T')
    large_char(char: 'R')
    large_char(char: 'Y')
    large_char(char: 'sp')
    large_char(char: 'A')
    large_char(char: 'dt')
    large_char(char: 'I')
    large_char(char: 'dt')
    Curses.refresh
    sleep(7)
    # set cycn to text colour (black background)
    Curses.init_pair(COLOR_CYAN,COLOR_CYAN,COLOR_BLACK)
    Curses.curs_set(1)
  end

  def heading(x:, y:)
    Curses.clear
    Curses.echo
    put_str(x: x, y: y, clr: COLOR_CYAN, str: 'G&S Dietry Pantry A.I.')
    put_str(clr: COLOR_RED,              str: '======================')
  end  

  def put_str(x: -1, y: -1, clr: nil, str:)
    @color = clr if clr
    set_pos(x: x, y: y)
    Curses.attron(color_pair(@color)|A_NORMAL) { Curses.addstr(str) }
  end  

  # normal text strings auto advences down the screen unless X, Y coordinated passed
  def set_pos(x: -1, y: -1)
    x > -1 ? @x = x : @x += 1
    @y = y if y > -1
    Curses.setpos(@x, @y)
  end  

  # large font charaters auto advance accross the screen unless X, Y coordinates passed
  # puts 1 charater per call
  def large_char(char:, x: -1, y: -1, clr: nil)
    y = @y if y == -1
    x = @x if x == -1
    save_y = y
    save_x = x
    set_pos(x: x, y: y) 
    @fcolor = clr if clr 
    
    @font[char.to_sym].each do |bitmap|
      bitmap.each do |str|
        str == '1' ? put_str(x: x, y: y, clr: @fcolor, str: ' ') : put_str(x: x, y: y, clr: COLOR_BLACK, str: ' ')
        y += 1        
      end  
      x += 1
      y = save_y
    end
    @y = y + 7 
    @x = save_x
  end

#   def show
#     Curses.init_screen
#     begin
#       Curses.crmode
#     # show_message("Hit any key")
#       Curses.setpos((Curses.lines - 5) / 2, (Curses.cols - 10) / 2)  # lines - 29 = top, lines - 1 = bottom 
#       Curses.addstr("Hit any key")
#       Curses.refresh
#       char = Curses.getch
#       show_message("You typed: #{char}")
#       Curses.refresh
#     ensure
#       Curses.close_screen
#     end
#   end  

#   def show_message(message)
#    width = message.length + 6
#    win = Curses::Window.new(5, width,
#  		   (Curses.lines - 5) / 2, (Curses.cols - width) / 2)
#    win.box('|', '-')
#    win.setpos(2, 3)
#    win.addstr(message)
#    win.refresh
#    win.getch
#    win.close
#  end

end  