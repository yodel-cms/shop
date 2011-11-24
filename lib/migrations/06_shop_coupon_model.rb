class ShopCouponModelMigration < Migration
  def self.up(site)
    site.records.create_model :coupons do |coupons|
      add_field :code, :string
      add_field :value, :decimal
    end
    
    site.records.create_model :coupon_redemptions do |coupon_redemptions|
      add_one :user
      add_one :coupon
    end
  end
  
  def self.down(site)
    site.coupons.destroy
    site.coupon_redemptions.destroy
  end
end
