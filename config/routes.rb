Rails.application.routes.draw do
  
  post 'order_complete' => 'cart#order_complete'

  get 'all_users' => 'admin#all_users'

  post 'edit_user' => 'admin#edit_user'

  get 'show_user' => 'admin#show_user'

  post 'add_to_cart' => 'cart#add_to_cart'

  get 'view_order' => 'cart#view_order'

  get 'checkout' => 'cart#checkout'

  devise_for :users
  
  root to: 'storefront#all_items'

  get 'products' => 'products#index'

  get 'categories' => 'storefront#items_by_category'

  get 'branding' => 'storefront#items_by_brand'
  
  

  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
