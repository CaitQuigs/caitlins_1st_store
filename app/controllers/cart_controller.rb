class CartController < ApplicationController
  
  before_action :authenticate_user!, except: [:add_to_cart, :view_order]
  
  # This check array stuff to make sure that we just update the quantity for the same item, doesn't work.
  def add_to_cart
    product = Product.find(params[:product_id])
    if (product.quantity - params[:quantity].to_i) < 0
      flash[:notice] = "There are only #{product.quantity} #{product.name} in stock. Please order fewer items."
      redirect_back(fallback_location: root_path)
    else
      line_item = LineItem.where(product_id: params[:product_id].to_i).first
      if line_item.blank?
        line_item = LineItem.create(product_id: params[:product_id].to_i, quantity: params[:quantity].to_i)
        line_item.update(line_item_total: line_item.quantity * line_item.product.price)
      else
        new_quantity = line_item.quantity + params[:quantity].to_i
        line_item.update(quantity: new_quantity)
        line_item.update(line_item_total: line_item.quantity * line_item.product.price)
      end
      redirect_back(fallback_location: root_path)
    end
  end
  
  def order_complete
    @order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i

    customer = Stripe::Customer.create( 
      :email => current_user.email,
      :card => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer => customer.id,
      :amount => @amount,
      :description => 'Rails Stripe customer',
      :currency => 'usd'
    )

    rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to cart_path
  end

  def view_order
    @line_items = LineItem.all
    @cart_total = 0
    @line_items.each do |item|
      @cart_total += item.line_item_total
    end
  end

  def checkout
    line_items = LineItem.all
    @order = Order.create(user_id: current_user.id, subtotal: 0)
    
    line_items.each do |line_item|
      line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
      @order.order_items[line_item.product_id] = line_item.quantity
      @order.subtotal += line_item.line_item_total
    end
    @order.save
    
    @order.update(sales_tax: (@order.subtotal * 0.08))
    @order.update(grand_total: (@order.sales_tax + @order.subtotal))
    
    line_items.destroy_all
  end
end
