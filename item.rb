class Item

  @next = 0

  class << self
    attr_accessor :next
    def next_id
      @next += 1
    end
  end    

  attr_reader :id, :expiry_date
  attr_accessor :barcode, :name, :quantity, :brand, :category, :rating, :supplier_id, :content_list, :consumption

  def initialize(barcode:, name:, quantity:, brand:, category: 1, rating:, expiry_date:, supplier_id:, content_list:, consumption: 1)
    @id = Item.next_id
    @barcode = barcode.to_i
    @name = name
    @quantity = quantity.to_f
    @brand = brand
    # 1 ???
    @category = category.to_i
    @rating = rating.to_i  # 9 = healthy, 0 = not at all healthy
    @expiry_date = Date.parse(expiry_date)
    @supplier_id = supplier_id.to_i
    @content_list = content_list
    @consumption = consumption.to_f
  end

  def expiry_date=(date)
    @expiry_date = Date.parse(date)
  end   

end
