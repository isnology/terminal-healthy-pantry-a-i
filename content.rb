class Content

  attr_accessor :name, :quantity

  def initialize(name:, quantity:)
    @name = name
    @quantity = quantity.to_f
  end  
end  
