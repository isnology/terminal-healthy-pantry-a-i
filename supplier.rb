class Supplier

  @next = 0

  class << self
    attr_accessor :next
    def next_id
      @next += 1
    end
  end      

  attr_reader :id
  attr_accessor :name, :item, :location

  def initialize(name:, sup_item: nil, location:)
    @id = Supplier.next_id
    @name = name
    @item = {} 
    @item.store(sup_item.id, sup_item) if sup_item
    @location = location 
  end 

  def add_sup_item(sup_item: sup_item)
    @item.store(sup_item.id, sup_item)
  end  

  def remove_item(sup_item: sup_item)
    @item.delete(sup_item.id)
  end  
end
