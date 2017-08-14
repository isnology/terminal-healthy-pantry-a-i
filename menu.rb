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
        stock_adjustment 
      when 4
        scan_mode(mode: 'OUT')   
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

  def stock_adjustment

  end

  def scan_mode(mode:)
    Curses.close_screen

    if mode == 'OUT'
      @display.auto_scan_mode_details
    else  
      @display.scan_all_items_in_pantry_details
    end  

    @scanner = Scanner.new(ip: '10.1.7.142', object: self, mode: mode)

    loop do
      #str = STDIN.gets.strip
      str = gets.strip
      break if str.to_i == 90
    end

    @scanner.close

    Curses.init_screen
  end  

  def scanned_in(barcode:)
    puts 'in'
    inventory = @pantry.inventories[barcode]
    inventory.quantity += 1
    puts inventory

    item = @pantry.master_items[inventory.item_id]
    puts item
    puts "#{barcode} item: #{item.name} qty: #{inventory.quantity}"
  end

  def scanned_out(barcode:)
    puts 'out'
    inventory = @pantry.inventories[barcode]
    inventory.quantity -= inventory.consumption

    item = @pantry.master_items[inventory.item_id]
    puts "#{barcode} item: #{item.name} qty: #{inventory.quantity}"
  end
end  