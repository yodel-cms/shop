class ShopModelFunctionsMigration < Migration
  def self.up(site)
    site.products.modify do |products|
      add_field :total_cost, :function, fn: 'sum(price, shipping, tax)'
    end
    
    site.product_holds.modify do |products|
      add_field :total_cost, :function, fn: 'multiply(product.total_cost, quantity)'
    end
    
    site.carts.modify do |carts|
      add_field :total_cost, :function, fn: 'product_holds.sum(total_cost)'
    end
    
    site.transactions.modify do |transactions|
      remove_field :product_total
      remove_field :shipping_total
      remove_field :tax_total
      remove_field :total
      
      modify_field :shipping_address do |shipping_address|
        remove_field :name
        add_field :first_name, :string
        add_field :last_name, :string
      end
      
      modify_field :billing_address do |billing_address|
        remove_field :name
        add_field :first_name, :string
        add_field :last_name, :string
      end
    end
  end
  
  def self.down(site)
  end
end
