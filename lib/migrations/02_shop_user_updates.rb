class ShopUserUpdatesMigration < Migration
  def self.up(site)
    site.users.modify do
      add_field :balance, :decimal, validations: {required: {}}, default: '0.0'
    end
  end
  
  def self.down(site)
    site.users.modify do
      remove_field :balance
    end
  end
end
