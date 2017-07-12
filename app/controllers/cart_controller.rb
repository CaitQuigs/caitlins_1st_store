class CartController < ApplicationController
  
  before_action :authenticate_user!, except: [:add_to_cart, :view_order]
  
  # This check array stuff to make sure that we just update the quantity for the same item, doesn't work.
  def add_to_cart
    # check = false
    
    # check_array = LineItem.all
    # check_array.each do |item|
    #   if item.product_id == params[:product_id].to_i
    #     check = true
    #     item.quantity += params[:quantity].to_i
    #     item.line_item_total = (item.quantity * line_item.product.price)
    #   end
    # end
    # check_array.save
    
    # line_item = LineItem.where(product_id: params[:product_id].to_i)
    #   if line_item.empty?
    #     line_item = LineItem.create(product_id: params[:product_id].to_i, quantity: params[:quantity].to_i)
    #     line_item.update(line_item_total: (line_item.quantity * line_item.product.price))
    #     redirect_back(fallback_location: root_path)
    #   else
    #     line_item.update(quantity: line_item.quantity + (params[:quantity].to_i), line_item_total: (line_item.quantity * line_item.product.price))
    #   end
      

    # if check == false
      line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])
      line_item.update(line_item_total: (line_item.quantity * line_item.product.price))
      redirect_back(fallback_location: root_path)
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
