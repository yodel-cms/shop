class ShopTransactionModelMigration < Migration
  def self.up(site)
    site.records.create_model :transactions do |transactions|
      add_one   :cart
      add_field :product_total, :decimal, default: '0.0', validations: {required: {}}
      add_field :shipping_total, :decimal, default: '0.0', validations: {required: {}}
      add_field :tax_total, :decimal, default: '0.0', validations: {required: {}}
      add_field :total, :function, fn: 'sum(product_total, shipping_total, tax_total)'
      add_field :created_at, :time
      
      add_embed_one :shipping_address do
        add_field :name, :string
        add_field :address, :string
        add_field :city, :string
        add_field :state, :string
        add_field :country, :string
        add_field :postcode, :string
        add_field :phone, :string
        add_field :email, :string
      end
      
      add_embed_one :billing_address do
        add_field :name, :string
        add_field :address, :string
        add_field :city, :string
        add_field :state, :string
        add_field :country, :string
        add_field :postcode, :string
        add_field :phone, :string
        add_field :email, :string
      end
      
      add_field :payment_reference, :string
      
      # permissions
      users_group = site.groups['Users'].id
      transactions.view_group = users_group
      transactions.create_group = users_group
      transactions.update_group = users_group
      transactions.delete_group = users_group
    end
    
    site.pages.create_model :transaction_pages do |transaction_pages|
      transaction_pages.record_class_name = 'TransactionPage'
    end
  end
  
  def self.down(site)
    site.transactions.destroy
    site.transaction_pages.destroy
  end
end
