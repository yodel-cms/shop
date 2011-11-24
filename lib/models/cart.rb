class Cart < Record
  CART_HOLD_DURATION = 10 * 60 # 10 minutes
  
  before_destroy :delete_all_product_holds    
  def delete_all_product_holds
    product_holds.each(&:destroy)
  end
  
  def self.perform_destroy_stale_carts(site)
    # ignore carts which have been purchased
    query = site.carts.where(transaction: nil)
    query = query.where(updated_at: {'$lt' => Time.at(Time.now.utc.to_i - CART_HOLD_DURATION)})
    query.all.each(&:destroy)
  end
end
