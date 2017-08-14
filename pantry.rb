require_relative 'content'
require_relative 'item'
require_relative 'inventory'
require_relative 'supplier'
require_relative 'menu'
require_relative 'display'
require_relative 'scanner'
require 'date'
require 'rubygems'
require 'websocket-client-simple'
require 'mail'
require 'yaml'
require 'curses'
#require 'espeak'
require 'irb'

include Curses
#include ESpeak

class Pantry

  FILE_NAME = 'system.yaml'
  FILE_BACK = 'system.back'

  attr_reader :inventories, :suppliers, :master_items
  attr_accessor :cycle, :date, :email, :scanner

  def initialize
    @inventories = {}
    @suppliers = {}
    @master_items = {}
    @cycle = 7
    @date = Date.today
    @email = ''

    @display = Display.new(self)
    @menu = Menu.new(self, @display)

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

  def add_inventory(barcode:, inventory:)
    @inventories.store(barcode, inventory)
  end

  def add_supplier(supplier:)
    @suppliers.store(supplier.id, supplier)
  end

  def add_master_item(item:)
    @master_items.store(item.id, item)
  end

  def remove_inventory(inventory:)
    @inventories.delete(inventory.id)
  end  

  def remove_supplier(supplier:)
    @suppliers.delete(supplier.id)
  end  

  def remove_master_item(item:)
    @master_items.delete(item.id)
  end  

  def shopping_list
    email_body =  " Coles Shopping List\r\n"
    email_body << " ===================\r\n\r\n"
    @inventories.each do |key, inventory|
      if inventory.quantity <= inventory.minimum_stock
        item = @master_items[inventory.item_id]
        email_body << " #{inventory.reorder_qty} of #{item.name}/s made by #{item.brand}\r\n"
      end  
    end  

    if email_body.length > 43
      email_body << "\r\n End Of List\r\n"

      # email list
      email = @email
      Mail.deliver do
      to       "#{email},"
      from     'grmarks@gmail.com'
      subject  'Shopping List from G&S Dietry Pantry A.I.'
      body     email_body
    end  
  end

  end

  def load_system
    if File.exists?(FILE_NAME)
      save = YAML.load(File.read(FILE_NAME))
      @inventories = save[:inv] if save.key?(:inv)
      @suppliers = save[:sup] if save.key?(:sup)
      Supplier.next = save[:sup_id] if save.key?(:sup_id)
      @master_items = save[:item] if save.key?(:item)
      Item.next = save[:item_id] if save.key?(:item_id)
      @cycle = save[:cycle] if save.key?(:cycle)
      @date = save[:date] if save.key?(:date)
      @email = save[:email] if save.key?(:email)
    end  
  end
  
  def save_system
    save = {
      inv: @inventories, 
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
    @menu.scan_mode(mode: 'IN') 
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

    item = Item.new(
      barcode: 9112345678901, 
      name: 'Cambels Soup', 
      quantity: 500, 
      brand: 'Cambels', 
      rating: 7,
      expiry_date: Date.parse('2018-05-01'), 
      content_list: contents
    )

    add_master_item(item: item)
    supplier.add_item(item_id: item.id, price: 7.50)
    inventory = Inventory.new(item_id: item.id, quantity: 4, minimum_stock: 2, reorder_qty: 4, consumption: 1)
    add_inventory(barcode: item.barcode, inventory: inventory)

    item = Item.new(
      barcode: 9112345678992, 
      name: 'Rice', 
      quantity: 1000, 
      brand: 'Sunlong', 
      rating: 8,          
      expiry_date: Date.parse('2018-01-01'), 
      content_list: contents
    )

    add_master_item(item: item)
    supplier.add_item(item_id: item.id, price: 5.40)
    supplier2.add_item(item_id: item.id, price: 8.50)
    inventory = Inventory.new(item_id: item.id, quantity: 2, minimum_stock: 1, reorder_qty: 1, consumption: 1)
    add_inventory(barcode: item.barcode, inventory: inventory)

    contents << Content.new(name: 'Gluten', quantity: 0.1)

    item = Item.new(
      barcode: 9112345678883, 
      name: 'Wholemeal Flour', 
      quantity: 1000, 
      brand: 'Sunlong', 
      rating: 8,
      expiry_date: Date.parse('2018-11-01'),
      content_list: contents
    )

    add_master_item(item: item)
    supplier.add_item(item_id: item.id, price: 6.30)
    inventory = Inventory.new(item_id: item.id, quantity: 2, minimum_stock: 1, reorder_qty: 1, consumption: 1)
    add_inventory(barcode: item.barcode, inventory: inventory)

    contents = []
    contents << Content.new(name: 'Sodium', quantity: 0.124)
    contents << Content.new(name: 'Sugar', quantity: 0.05)

    item = Item.new(
      barcode: 8076809545396, 
      name: 'Pesti', 
      quantity: 190, 
      brand: 'Barilla', 
      rating: 6,
      expiry_date: Date.parse('2018-03-01'), 
      content_list: contents
    )

    add_master_item(item: item)
    supplier.add_item(item_id: item.id, price: 3.50)
    inventory = Inventory.new(item_id: item.id, quantity: 3, minimum_stock: 1, reorder_qty: 2, consumption: 1)
    add_inventory(barcode: item.barcode, inventory: inventory)

    contents = []
    contents << Content.new(name: 'Sodium', quantity: 0.2)
    contents << Content.new(name: 'Sugar', quantity: 0.1)

    item = Item.new(
      barcode: 4001724819103, 
      name: 'Pizza Funghi', 
      quantity: 3, 
      brand: 'Ristorante', 
      rating: 6,
      expiry_date: Date.parse('2018-07-01'), 
      content_list: contents
    )

    add_master_item(item: item)
    supplier.add_item(item_id: item.id, price: 7.20)
    #inventory = Inventory.new(item_id: item.id, quantity: 4, minimum_stock: 1, reorder_qty: 2, consumption: 1)
    #add_inventory(barcode: item.barcode, inventory: inventory)
  end

end
