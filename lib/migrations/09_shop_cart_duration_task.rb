class ShopCartDurationMigration < Migration
  def self.up(site)
    # duration is now stored outside a cart
    site.carts.modify do |carts|
      remove_field :hold_duration
    end
    
    # clean up carts every minute
    cart_task = Task.new(site)
    cart_task.type = 'perform_destroy_stale_carts'
    cart_task.repeat_in = 60
    cart_task.save
  end
  
  def self.down(site)
  end
end
