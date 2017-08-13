class Inventory

  @next = 0

  class << self
    attr_accessor :next
    def next_id
      @next += 1
    end
  end    

  attr_reader :id
  attr_accessor :item_id, :quantity, :minimum_stock

  def initialize(item_id:, quantity:, minimum_stock:)
    @id = Inventory.next_id
    @item_id = item_id.to_i
    @quantity = quantity.to_f
    @minimum_stock = minimum_stock.to_f
  end

end
