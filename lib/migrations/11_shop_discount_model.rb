class ShopDiscountModelMigration < Migration
  def self.up(site)
    site.records.create_model :discounts do |discounts|
      add_field :amount, :integer, validations: {required: {}}, default: '0.0'
    end
    
    site.carts.modify do |carts|
      add_many :discounts
      modify_field :total_cost, fn: 'subtract(product_holds.sum(total_cost), discounts.sum(amount))'
    end
  end
  
  def self.down(site)
    site.discounts.destroy
    site.carts.modify do |carts|
      remove_field :discounts
    end
  end
end
