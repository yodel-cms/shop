class ShopCartModelMigration < Migration
  def self.up(site)
    site.records.create_model :carts do |carts|
      add_field :session_id, :string
      add_one   :user, index: true
      add_many  :product_holds, foreign_key: 'cart', destroy: true
      add_field :created_at, :time
      add_field :updated_at, :time
      add_field :hold_duration, :integer, default: 600
      add_one   :transaction, index: true
      carts.record_class_name = 'Cart'
      
      # permissions
      users_group = site.groups['Users'].id
      carts.view_group = users_group
      carts.create_group = users_group
      carts.update_group = users_group
      carts.delete_group = users_group
    end
    
    site.pages.create_model :cart_pages do |cart_pages|
      cart_pages.record_class_name = 'CartPage'
    end
  end
  
  def self.down(site)
    site.carts.destroy
    site.cart_pages.destroy
  end
end
