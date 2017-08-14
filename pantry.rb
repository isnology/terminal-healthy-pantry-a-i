require_relative 'content'
require_relative 'item'
require_relative 'inventory'
require_relative 'supplier'
require_relative 'menu'
require_relative 'display'
#require 'rubyserial'
require 'date'
require 'rubygems'
require 'websocket-client-simple'
require 'mail'
require 'yaml'
require 'curses'
#require 'espeak'
#require 'irb'

include Curses
#include ESpeak

class Pantry

  FILE_NAME = 'system.yaml'
  FILE_BACK = 'system.back'

  attr_accessor :cycle, :date, :email, :scanner, :mode

  def initialize
    @inventories = {}
    @suppliers = {}
    @master_items = {}
    @cycle = 7
    @email = ''
    @date = Date.today
    @mode = 'out'

    @display = Display.new(self)
    @menu = Menu.new(self, @display)
    #@serialport = Serial.new '/dev/ttyACM0', 19200, 8, :even
    #@serialport = Serial.new '/dev/tty.GlennGS7e-BlueScanner'
    @scanner = WebSocket::Client::Simple.connect 'ws://10.1.7.142:9999/' do |ws|
      ws.on :open do
        ws.send 'connected!'
      end  
    end

    @scanner.on :message do |msg|
      puts msg.data 
    end

    @scanner.on :close do |e|
      p e
      exit 1
    end

    @scanner.on :error do |e|
      p e
    end

    options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'localhost',
            :user_name            => 'grmarks',
            :password             => '',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

    Mail.defaults do
      delivery_method :smtp, options
    end
  end  

  def run
    begin
      load_system
      Curses.init_screen
      if !File.exists?(FILE_NAME)
        @display.splash_screen 
        on_startup
      else
        @display.splash_screen  
      end  
      @menu.main_menu
    ensure  
      Curses.close_screen
      save_system
    end  
  end  

  def add_inventory(inventory:)
    @inventories.store(inventory.id, inventory)
  end

  def add_supplier(supplier:)
    @suppliers.store(supplier.id, supplier)
  end

  def add_master_item(item:)
    @master_items.store(item.id, item)
    @suppliers[item.supplier_id].add_sup_item(sup_item: Sup_item.new(item_id: item.id, price: item.price)) 
  end

  def remove_inventory(inventory:)
    @inventories.delete(inventory.id)
  end  

  def remove_supplier(supplier:)
    @suppliers.delete(supplier.id)
  end  

  def remove_master_item(item:)
    @master_items.delete(item.id)
    @suppliers[item.supplier_id].remove_item(item)
  end  

  def shopping_list
    @inventories.each do |key, value|
      if value.quantity <= value.minimum_stock
        add_to_list(value)
      end  
    end  
    # email list

  end

  def load_system
    if File.exists?(FILE_NAME)
      save = YAML.load(File.read(FILE_NAME))
      @inventories = save[:inv] if save[:inv]
      Inventory.next = save[:inv_id] if save[:inv_id]
      @suppliers = save[:sup] if save[:sup]
      Supplier.next = save[:sup_id] if save[:sup_id]
      @master_items = save[:item] if save[:item]
      Item.next = save[:item_id] if save[:item_id]
      @cycle = save[:cycle] if save[:cycle]
      @date = save[:date] if save[:date]
      @email = save[:email] if save[:email]
    end  
  end
  
  def save_system
    save = {
      inv: @inventories, 
      inv_id: Inventory.next,
      sup: @suppliers, 
      sup_id: Supplier.next,
      item: @master_items, 
      item_id: Item.next,
      cycle: @cycle, 
      date: @date,
      email: @email
    }
    File.rename(FILE_NAME, FILE_BACK) if File.exists?(FILE_NAME) 
    File.open(FILE_NAME, 'w') do |file| 
      file.write(YAML.dump(save)) 
    end 
    File.delete(FILE_BACK) if File.exists?(FILE_BACK) 
  end  

  def on_startup
    @menu.email
    @menu.shopping_cycle
    supplier_download
  end

  def supplier_download
    # supplier downloads go here
    # simulate a download

    supplier = Supplier.new(name: 'Coles', location: 'Dandenong North')
    add_supplier(supplier: supplier)
    supplier2 = Supplier.new(name: 'Woolworths', location: 'Dandenong North')
    add_supplier(supplier: supplier2)

    contents = []
    contents << Content.new(name: 'Sodium', quantity: 0.1)
    contents << Content.new(name: 'Sugar', quantity: 0.1)
    item = Item.new(barcode: 9112345678901, name: 'Cambels Soup', quantity: 500, brand: 'Cambels', rating: 7,
                    expiry_date: '2018-05-01', supplier_id: supplier.id, content_list: contents)
    add_master_item(item: item)
    inventory = Inventory.new(item_id: item.id, quantity: 4, minimum_stock: 2)
    add_inventory(inventory: inventory)
    item = Item.new(barcode: 9112345678992, name: 'Rice', quantity: 1000, brand: 'Sunlong', rating: 8,
                    expiry_date: '2018-09-01', supplier_id: supplier.id, content_list: contents)
    add_master_item(item: item)
    inventory = Inventory.new(item_id: item.id, quantity: 2, minimum_stock: 1)
    add_inventory(inventory: inventory)
    contents << Content.new(name: 'Gluten', quantity: 0.1)
    item = Item.new(barcode: 9112345678883, name: 'Wholemeal Flour', quantity: 1000, brand: 'Sunlong', rating: 8,
                    expiry_date: '2018-11-01', supplier_id: supplier.id, content_list: contents)
    add_master_item(item: item)
    inventory = Inventory.new(item_id: item.id, quantity: 2, minimum_stock: 1)
    add_inventory(inventory: inventory)

    contents = []
    contents << Content.new(name: 'Sodium', quantity: 0.124)
    contents << Content.new(name: 'Sugar', quantity: 0.05)
    item = Item.new(barcode: 8076809545396, name: 'Pesti', quantity: 190, brand: 'Barilla', rating: 6,
                    expiry_date: '2018-05-01', supplier_id: supplier.id, content_list: contents)
    add_master_item(item: item)
    inventory = Inventory.new(item_id: item.id, quantity: 3, minimum_stock: 1)
    add_inventory(inventory: inventory)

    contents = []
    contents << Content.new(name: 'Sodium', quantity: 0.2)
    contents << Content.new(name: 'Sugar', quantity: 0.1)
    item = Item.new(barcode: 8076809545396, name: 'Pizza Funghi', quantity: 365, brand: 'Ristorante', rating: 6,
                    expiry_date: '2018-02-01', supplier_id: supplier.id, content_list: contents)
    add_master_item(item: item)
    inventory = Inventory.new(item_id: item.id, quantity: 4, minimum_stock: 2)
    add_inventory(inventory: inventory)
  end

  private

    def add_to_list(inventory)

    end  
end
