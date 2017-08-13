class Menu

  def initialize(pantry, display)
    @pantry = pantry
    @display = display
  end

  def main_menu
    begin
      option = @display.menu_details

      case option
      when 1
        email
      when 2
        shopping_cycle
      when 3
        scan_all_items  
      when 4
        auto_scan_mode   
      when 5
        @pantry.shopping_list    
      when 99
        #do nothing   
      else 
        @display.error_message(option)
        @display.pause  
      end
      
    end while option != 99
  end

  # list blue tooth ports   ls -l /dev/tty.*
  # my phone scanner /dev/tty.GlennGS73-BlueScanner
  # read(length : Int) -> String

  def email
    email = @display.email_details
    @pantry.email = email
  end

  def shopping_cycle
    cycle = @display.shopping_cycle_details
    @pantry.cycle = cycle[:cycle]
    @pantry.date = cycle[:date]
  end

  def scan_all_items
    Curses.close_screen

    @display.scan_all_items_in_pantry_details
    loop do
      str = STDIN.gets.strip
      break if str.to_i == 90
      if str[0, 5] == 'Demo '
        puts 'ignore ' + str
      else  
        @pantry.scanner.send str
      end   
    end

    Curses.init_screen
  end

  def auto_scan_mode
    Curses.close_screen

    @display.auto_scan_mode_details
    loop do
      str = STDIN.gets.strip
      break if str.to_i == 90
      if str[0, 5] == 'Demo '
        puts 'ignore ' + str
      else  
        @pantry.scanner.send str
      end   
    end

    Curses.init_screen
  end  
end  