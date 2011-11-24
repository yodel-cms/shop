class CouponRestrictionsMigration < Migration
  def self.up(site)
    site.coupon_redemptions.destroy
    
    site.coupons.modify do |coupons|
      add_field :user_restrictions, :hash
      add_field :product_restrictions, :hash
      add_field :value_type, :enum, options: %w{currency percent}, default: 'currency'
      add_many  :redemptions, model: :user
    end
  end
  
  def self.down(site)
    site.coupons.modify do |coupons|
      remove_field :user_restrictions
      remove_field :product_restrictions
      remove_field :value_type
      remove_field :redemptions
    end
  end
end
