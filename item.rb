class Item

  @next = 0

  class << self
    attr_accessor :next
    def next_id
      @next += 1
    end
  end    

  attr_reader :id
  attr_accessor :barcode, :name, :quantity, :brand, :rating, :content_list

  def initialize(barcode:, name:, quantity:, brand:, rating:, expiry_date:, content_list:)
    @id = Item.next_id
    @barcode = barcode.to_i
    @name = name
    @quantity = quantity.to_f
    @brand = brand
    @rating = rating.to_i  # 9 = healthy, 0 = not at all healthy
    @expiry_date = expiry_date
    @content_list = content_list
  end

end
