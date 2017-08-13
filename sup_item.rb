class SupItem

  attr_accessor :item_id, :price

  def initialize(item_id:, price:)
    @item_id = item_id
    @price = price
  end
end  
