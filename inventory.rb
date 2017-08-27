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

  def reorder?
    # reorder quanty = to 0 means ignore this item
    self.quantity <= self.minimum_stock && self.reorder_qty > 0
  end

  def increase(quantity: 1.0)
    self.quantity += quantity.to_f
    self
  end

  def decrease(quantity: 1.0)
    self.quantity -= self.consumption * quantity.to_f
    self.quantity = 0.0 if self.quantity < 0.0
    self
  end
end
