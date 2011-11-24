class ShopProductHoldModelMigration < Migration
  def self.up(site)
    site.records.create_model :product_holds do |product_holds|
      add_one   :product, validations: {required: {}}, index: true
      add_one   :cart, validations: {required: {}}, index: true
      add_field :quantity, :integer, default: 0, validations: {required: {}}
      add_field :sold, :boolean, default: false
      product_holds.record_class_name = 'ProductHold'
    end
  end
  
  def self.down(site)
    site.product_holds.destroy
  end
end
