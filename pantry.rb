class Pantry

  attr_reader :inventories, :suppliers, :master_items
  attr_accessor :cycle, :date, :email, :scanner

  def initialize
    @inventories = {}
    @suppliers = {}
    @master_items = {}
    @history = []
    @cycle = 7
    @date = Date.today
    @email = ''
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

  def reduce_inventory(barcode:)
    if inventory = inventories[barcode]
      inventory.decrease
    end
  end

  def increase_inventory(barcode:)
    if inventory = inventories[barcode]
      inventory.increase
    end
  end

  def inventory_reorder
    inventories = []
    @inventories.each do |key, inventory|
      if inventory.reorder?
        inventories << inventory
      end
    end
    inventories
  end

  def shopping_list(inventories:, type: nil)
    shopping_list = [" Shopping List"]
    shopping_list <<  " =============================\r\n"

    inventories.each do |inventory|
      item = @master_items[inventory.item_id]
      shopping_list << " #{type ? 1 : inventory.reorder_qty} of #{item.name} made by #{item.brand}"
    end

    shopping_list << "\r\n End Of List"
  end

  def adjust_reorder(inventories:, type:)
    inv_hist = {}
    count = {}
    @history.each do |hist|
      if count.key?(hist.item_id)
        count[hist.item_id] += 1
      else
        count[hist.item_id] = 1
      end
    end
    inventories.each do |inventory|
      if type == SCHEDULED
        if count[inventory.item_id] < 2
          if inventory.minimum_stock > 0
            inventory.minimum_stock -= 1;
          else
            inventory.reorder_qty -= 1 if inventory.reorder_qty > 1
          end
        elsif count[inventory.item_id] > 2
          if inventory.minimum_stock < 2
            inventory.minimum_stock += 1
          else
            inventory.reorder_qty += 1
          end
        end
      end
      inv_hist[Date.today].store(inventory.item_id, inventory)
    end
    reorder_history(inventories: inv_hist)
  end

  def reorder_history(inventories:)
    @history << inventories
    date = Date.today - (@cycle * 2)
    while @history.first[date] < date
      @history.shift
    end
  end

  def load_system
    if File.exists?(Constants::FILE_NAME)
      save = YAML.load(File.read(Constants::FILE_NAME))
      @inventories = save[:inv] if save.key?(:inv)
      @suppliers = save[:sup] if save.key?(:sup)
      Supplier.next = save[:sup_id] if save.key?(:sup_id)
      @master_items = save[:item] if save.key?(:item)
      Item.next = save[:item_id] if save.key?(:item_id)
      @history = save[:history] if save.key?(:history)
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
      history: @history,
      cycle: @cycle,
      date: @date,
      email: @email
    }

    File.rename(Constants::FILE_NAME, Constants::FILE_BACK) if File.exists?(Constants::FILE_NAME)
    File.open(Constants::FILE_NAME, 'w') do |file|
      file.write(YAML.dump(save))
    end
    File.delete(Constants::FILE_BACK) if File.exists?(Constants::FILE_BACK)
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
    inventory = Inventory.new(item_id: item.id, quantity: 4.0, minimum_stock: 2.0, reorder_qty: 4, consumption: 1.0)
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
    inventory = Inventory.new(item_id: item.id, quantity: 2.0, minimum_stock: 1.0, reorder_qty: 1, consumption: 1.0)
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
    inventory = Inventory.new(item_id: item.id, quantity: 2.0, minimum_stock: 1.0, reorder_qty: 1, consumption: 1.0)
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
    inventory = Inventory.new(item_id: item.id, quantity: 3.0, minimum_stock: 1.0, reorder_qty: 2, consumption: 1.0)
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
