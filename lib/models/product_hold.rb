class ProductHold < Record
  after_destroy :increment_quantity
  def increment_quantity
    return if product.unlimited_quantity
    product.increment! :quantity
  end
end
