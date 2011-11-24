class CartPage < Page
  def products
    cart.product_holds.collect(&:product)
  end

  def hold_product(product, quantity)
    # TODO: find_or_create
    # use any existing holds for this product
    hold = site.product_holds.where(product: product.id, cart: cart.id).first
    hold ||= site.product_holds.new(product: product, cart: cart)
  
    if product.quantity >= quantity
      if product.increment! :quantity, -quantity, :quantity.gt => 0
        hold.quantity += quantity
        return hold.save
      end
    end
    false
  end

  def cart
    if logged_in?
      @cart ||= site.carts.where(transaction: nil, user: current_user.id).order('created desc').first
    else
      # TODO: need to track by session
      nil
    end
  end

  respond_to :post do
    with :html do
      return unless user_allowed_to?(:create)
    
      # we're creating a new cart, so delete any existing (current) carts
      site.carts.where(transaction: nil, user: current_user.id).all.each(&:destroy)
    
      # create a new cart to hold any products sent in the request
      @cart = site.carts.new(user: current_user, name: current_user.name)
      @cart.save
    
      # if any products were added to the cart, create holds on them
      flash[:failed] = []
    
      params['products'].each do |product_options|
        product = site.products.where(_id: BSON::ObjectId.from_string(product_options['id'])).first
        quantity = product_options['quantity'].to_i
        unless product.unlimited_quantity || hold_product(product, quantity)
          flash[:failed] << product_options['id']
        end
      end
    
      # finally render the cart page
      cart.reload
      respond_to_get_with_html
    end
  end

  respond_to :put do
    with :html do
      return unless user_allowed_to?(:update)
      # FIXME: implement
    end
  end

end
