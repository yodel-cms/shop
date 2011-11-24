class ShopProductModelMigration < Migration
  def self.up(site)
    site.pages.create_model :products do |products|
      add_field :price, :decimal, validations: {required: {}}, default: '0.0'
      add_field :shipping, :decimal, validations: {required: {}}, default: '0.0'
      add_field :tax, :decimal, validations: {required: {}}, default: '0.0'
      add_field :unlimited_quantity, :boolean, validations: {required: {}}, default: false
      add_field :quantity, :integer, validations: {required: {}}, default: 0, index: true
      add_many  :holds, model: :product_hold
    end
  end
  
  def self.down(site)
    site.products.destroy
  end
end
