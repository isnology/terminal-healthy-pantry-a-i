require_relative 'content'
require_relative 'item'
require_relative 'inventory'
require_relative 'supplier'
require_relative 'pantry'
require_relative 'display'
require_relative 'scanner'
require_relative 'constants'
require 'date'
require 'rubygems'
require 'websocket-client-simple'
require 'mail'
require 'yaml'
require 'curses'
require 'irb'

include Curses
include Constants

class Menu

  def initialize
    @pantry = Pantry.new
    @display = Display.new

    options = { 
            :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'localhost',
            :user_name            => 'grmarks',
            :password             => ENV['EMAIL_PASSWORD'],
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

    Mail.defaults do
      delivery_method :smtp, options
    end        
  end

  def run
    begin
      @pantry.load_system
      Curses.init_screen
      @display.splash_screen 
      on_startup if !File.exists?(FILE_NAME)
      pantry = @pantry
      Thread.new { background_task(pantry: pantry) } 
      main_menu 
    ensure  
      Curses.close_screen
      @pantry.save_system
    end  
  end  

  def on_startup
    email
    shopping_cycle
    @pantry.supplier_download
    scan_mode(mode: 'IN') 
  end

  def background_task(pantry:)
    loop do
      time = Time.now
      if time.mday == pantry.date.mday && time.hour == 10
        inventories = @pantry.inventory_reorder
        @pantry.adjust_reorder(inventories: inventories, type: SCHEDULED)
        shopping_list = @pantry.shopping_list(inventories: inventories)  
        email_shopping_list(shopping_list)
      end
      sleep(3600) # 1 hour  
    end  
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
        shopping_list
      when 99
        #do nothing   
      else 
        @display.error_message(option)
        @display.pause  
      end
      
    end while option != 99
  end

  def email
    email = @display.email_details
    @pantry.email = email
  end

  def shopping_cycle
    cycle = @display.shopping_cycle_details
    @pantry.cycle = cycle[:cycle]
    @pantry.date = cycle[:date]
  end

  def shopping_list
    inventories = @pantry.inventory_reorder
    shopping_list = @pantry.shopping_list(inventories: inventories)  
    email_shopping_list(shopping_list)
  end

  def email_shopping_list(shopping_list)
    if shopping_list.length > 3  
      email = @pantry.email
      Mail.deliver do
        to       "#{email},"
        from     'grmarks@gmail.com'
        subject  'Shopping List from G&S Dietry Pantry A.I.'
        body     shopping_list.join("\r\n")
      end  
    end  
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
      str = STDIN.gets.strip
      break if str.to_i == 90
    end

    @scanner.close

    Curses.init_screen
  end  

  def scanned_in(barcode:)
    i_barcode = barcode.to_i
    if @pantry.inventories.key?(i_barcode)
      inventory = @pantry.increase_inventory(barcode: i_barcode)
      item = @pantry.master_items[inventory.item_id]
      puts "#{barcode} item: #{item.name} qty: #{inventory.quantity} increase"  
    else  
      # create inventory record
      @pantry.master_items.each do |key, item|
        if item.barcode == i_barcode
          inventory = Inventory.new(item_id: item.id, quantity: 1.0, minimum_stock: 1.0, reorder_qty: 2, consumption: 1.0)
          @pantry.add_inventory(barcode: i_barcode, inventory: inventory)
          puts "add #{barcode} item: #{item.name} qty: #{inventory.quantity} to inventory"  
          break
        end
      end  
    end  
  end

  def scanned_out(barcode:)
    inventory = @pantry.reduce_inventory(barcode: barcode.to_i)
    item = @pantry.master_items[inventory.item_id]
    puts "#{barcode} item: #{item.name} qty: #{inventory.quantity} decrease (unless 0.0)"
    if inventory.reorder?
      @pantry.adjust_reorder(inventories: [inventory], type: LOW_STOCK)
      shopping_list = @pantry.shopping_list(inventories: [inventory], type: LOW_STOCK)  
      email_shopping_list(shopping_list)
    end  
  end
end  