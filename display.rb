
class Display

  def initialize
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
    heading(x: 8, y: 20)
    z = 0
    put_str(str: "#{z += 1}.  Email Details", y: 28, clr: COLOR_GREEN)
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
    heading(x: 8, y: 20)
    set_pos
    put_str(str: 'Please Enter your email: ', clr: COLOR_GREEN)
    Curses.refresh
    Curses.getstr
  end

  def shopping_cycle_details
    hash = {}
    heading(x: 8, y: 20)
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

    y = 4
    ['P', 'A', 'N', 'T', 'R', 'Y', 'sp', 'A', 'dt', 'I', 'dt'].each do |char|
      (-3..14).each do |x|
        large_char(char: char, x: x, y: y, clr: COLOR_CYAN)
        Curses.refresh
        sleep(0.02)
      end  
      y += 7
    end
    
    y = 5
    ['G', 'as', 'S', 'sp', 'D', 'I', 'E', 'T', 'R', 'Y'].each do |char|
      (-3..5).each do |x|
        large_char(char: char, x: x, y: y, clr: COLOR_CYAN)
        Curses.refresh
        sleep(0.05)
      end 
      y += 7  
    end
    
    Curses.refresh
    sleep(5)
    # set cycn to text colour (black background)
    Curses.init_pair(COLOR_CYAN,COLOR_CYAN,COLOR_BLACK)
    Curses.curs_set(1)
  end

  def heading(x:, y:)
    Curses.clear
    Curses.echo
    put_str(x: x, y: y, clr: COLOR_CYAN, str: 'G & S   D i e t r y   P a n t r y   A. I.')
    put_str(clr: COLOR_RED,              str: '=========================================')
    set_pos
  end  

  # put a string to the screen (with colour) using Curses (remember colour)
  def put_str(x: -10, y: -10, clr: nil, str:)
    @color = clr if clr
    set_pos(x: x, y: y)
    Curses.attron(color_pair(@color)|A_NORMAL) { Curses.addstr(str) } 
  end  

  # normal text strings auto advences down the screen unless X, Y coordinated passed
  def set_pos(x: -10, y: -10)
    x > -10 ? @x = x : @x += 1
    @y = y if y > -10
    Curses.setpos(@x, @y)
  end  

  # large font charaters auto advance accross the screen unless X, Y coordinates passed
  # puts 1 character per call
  def large_char(char:, x: -10, y: -10, clr: nil)
    y = @y if y == -10
    x = @x if x == -10
    save_x = x
    save_y = y
    set_pos(x: x, y: y) 
    @fcolor = clr if clr 
    
    if x > -1
      put_str(x: x-1, y: y, clr: COLOR_BLACK, str: '     ')
      @font[char.to_sym].each do |bitmap|
        bitmap.each do |str|
          str == '1' ? put_str(x: x, y: y, clr: @fcolor, str: ' ') : put_str(x: x, y: y, clr: COLOR_BLACK, str: ' ')
          y += 1        
        end  
        x += 1
        y = save_y
      end
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