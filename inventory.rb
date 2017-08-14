class Inventory

  attr_reader :id
  attr_accessor :item_id, :quantity, :minimum_stock, :reorder_qty, :consumption

  def initialize(item_id:, quantity:, minimum_stock: 1, reorder_qty: 2, consumption: 1)
    @item_id = item_id
    @quantity = quantity.to_f
    @minimum_stock = minimum_stock.to_f
    @reorder_qty = reorder_qty.to_i
    @consumption = consumption.to_f
  end

end
