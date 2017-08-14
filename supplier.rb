class Supplier

  @next = 0

  class << self
    attr_accessor :next
    def next_id
      @next += 1
    end
  end      

  attr_reader :id, :items
  attr_accessor :name, :location

  def initialize(name:, location:)
    @id = Supplier.next_id
    @name = name
    @items = {} 
    @location = location 
  end 

  def add_item(item_id:, price:)
    @items.store(item_id, price)
  end  
end
