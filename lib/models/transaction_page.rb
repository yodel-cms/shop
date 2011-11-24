class TransactionPage < Page
  
  # TODO: find way to abstract this
  def cart
    if logged_in?
      @cart ||= site.carts.where(transaction: nil, user: current_user.id).order('created desc').first
    else
      # TODO: need to track by session
      nil
    end
  end
  
  def successful?
    @successful
  end
  
  def products
    cart.product_holds.collect(&:product)
  end
  
  respond_to :post do
    with :html do
      return unless user_allowed_to?(:create)
      
      # update the cart from the checkout form (e.g to include discounts)
      cart.from_json(params['cart']) if params['cart']
      
      # FIXME: race condition (user a window 1, user a window 2, both doing purchases, inconsistent charge)
      # Unable to do an atomic update because big decimals are stored as strings... store as int (*100)??
      current_user.balance -= cart.total_cost
      current_user.save_without_validation
      transaction_successful = false
      transaction_id = BSON::ObjectId.new
      
      if current_user.balance < 0
        gateway = ActiveMerchant::Billing::PayWayGateway.new(
          username: 'Q14555',
          password: 'Au5xh8v8g',
          merchant: '23891864',
          pem: File.join(site.root_directory, 'ccapi.pem'),
          eci: 'SSL'
        )
        
        # construct an expiry month & date from a date string or separate m/y values
        if params['expiry_month'] && params['expiry_year']
          expiry_month = params['expiry_month']
          expiry_year = params['expiry_year']
        else
          begin
            expiry = Date.parse(params['expiry'].to_s)
            expiry_month = expiry.month.to_s
            expiry_year = expiry.year.to_s
          rescue
            expiry_month = expiry_month = nil
          end
        end
        
        # ignore spaces and any non numeric characters
        card_number = params['card_number'].scan(/\d+/).join
        
        # use the current user's name if no other name is provided
        first_name = params['first_name'] || current_user.first_name
        last_name = params['last_name'] || current_user.last_name
        
        card = ActiveMerchant::Billing::CreditCard.new(
          number: card_number,
          month: expiry_month,
          year: expiry_year,
          first_name: first_name,
          last_name: last_name,
          verification_value: params['verification']
        )
        
        if card.valid?
          order_number = [transaction_id.data.collect(&:chr).join].pack('m0')
          result = gateway.purchase((current_user.balance * -100).to_i, card, order_number: order_number)
          if result.success?
            payment_reference = result.params['receipt_no']
            transaction_successful = true
          else
            flash[:transact_error] = result.message
          end
        else
          flash[:card_error] = card.errors.collect {|field, val| "#{field.humanize} #{val.to_sentence}"}.join('. ')
        end
      else
        payment_reference = 'Positive Balance'
        transaction_successful = true
      end
      
      if transaction_successful
        transaction = site.transactions.new(cart: cart)
        transaction.set_id(transaction_id)
        
        # billing
        transaction.billing_address.first_name = params['first_name']
        transaction.billing_address.last_name = params['last_name']
        
        # shipping
        transaction.shipping_address.first_name = current_user.first_name
        transaction.shipping_address.last_name = current_user.last_name
        transaction.shipping_address.address = current_user.address
        transaction.shipping_address.state = current_user.state
        transaction.shipping_address.city = current_user.city
        transaction.shipping_address.postcode = current_user.postcode
        transaction.shipping_address.phone = current_user.phone
        transaction.shipping_address.email = current_user.email
        
        # transaction
        transaction.payment_reference = payment_reference
        transaction.save
        
        # mark the products as sold
        # TODO: switch to hold.update(sold: true)
        cart.product_holds.each do |hold|
          hold.sold = true
          hold.save
        end
        
        cart.transaction = transaction
        cart.save
        
        @successful = true
        respond_to_get_with_html()
      else
        current_user.balance += cart.total_cost
        current_user.save_without_validation
        flash[:first_name] = params['first_name']
        flash[:last_name] = params['last_name']
        flash[:expiry] = params['expiry']
        flash[:card_number] = params['card_number']
        flash[:verification] = params['verification']
        response.redirect('/cart')
      end
    end
  end
  
end
