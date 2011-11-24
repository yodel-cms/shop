class CouponRedemptionPage < Page
  respond_to :post do
    with :html do
      user = current_user
      coupon = site.coupons.where(code: params['coupon_code']).first
      
      if user && coupon
        unless coupon.redemptions.include?(user)
          if user_permitted_to_redeem?(user, coupon)
            coupon.redemptions << user
            coupon.save
        
            # FIXME: needs to be atomic and respect percent value_type
            user.balance += coupon.value
            user.save_without_validation
            flash[:coupon_successfully_redeemed] = true
          else
            flash[:failed_redemption_rules] = true
          end
        else
          flash[:coupon_already_redeemed] = true
        end
      else
        flash[:coupon_not_found] = true
      end
      
      response.redirect redirect_to.path
    end
  end
  
  private
    def user_permitted_to_redeem?(user, coupon)
      return true if coupon.user_restrictions.blank?
      
      coupon.user_restrictions.each do |field, restriction|
        # TODO: support other restriction types
        if restriction.is_a?(Array)
          return false unless restriction.include?(user.get(field))
        end
      end
      
      true
    end
end
