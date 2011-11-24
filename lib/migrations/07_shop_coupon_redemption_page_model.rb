class CouponRedemptionPageModelMigration < Migration
  def self.up(site)
    site.pages.create_model :coupon_redemption_pages do |coupon_redemption_pages|
      add_one :redirect_to, model: :page
      coupon_redemption_pages.record_class_name = 'CouponRedemptionPage'
    end
  end
  
  def self.down(site)
    site.coupon_redemption_pages.destroy
  end
end
