require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "dotenv"
Dotenv.load

require_relative "shop_database.rb"
require_relative "helpers.rb"

# Update server without relaunching
configure(:development) do
  require "sinatra/reloader"
  also_reload "shop_database.rb"
  also_reload "helpers.rb"
  also_reload "public/stylesheets/styles.css"
end

# Establish browser sessions and escape any html injection
configure do
  enable :sessions
  set :session_secret, "04c032bd7c1c48804f6482d29e02e582847579c704dc9ff61ee467d9bc7cacca"
  set :erb, :escape_html => true
end

# Initialize database connection
before do
  @database = ShopDatabase.new(logger)
end

# Sign in page
get "/signin" do
  redirect "/" if user_signed_in?
  erb :signin, layout: :layout
end

# Sign in page
post "/signin" do
  user = params[:username]
  pass = params[:password]
  if valid_user?(user, pass)
    session[:signin] = user
    session[:success] = "You've been successfully signed in as #{user}"
    redirect session.delete(:next_path)
  else
    register_errors("Username and password did not match any existing users")
    erb :signin, layout: :layout
  end
end

# Sign out button
post "/signout" do
  session[:success] = "You have been signed out from #{session.delete(:signin)}"
  redirect "/signin"
end

# View all shops, 5 at a time
get "/shops/page/:page" do
  check_sign_in
  @shops = @database.all_shops
  @page = find_page(@shops)
  erb :shops, layout: :layout
end

# Create New Shop
get "/shops/new" do
  check_sign_in
  erb :new_shop, layout: :layout
end

post "/shops/new" do
  check_sign_in
  if shop_name_error?
    erb :new_shop, layout: :layout
  else
    @database.create_new_shop(params[:shop_name])
    session[:success] = "#{params[:shop_name]} has been successfuly created"
    redirect "/"
  end
end

# View shop page with products
get "/shops/:shop_id/page/:page" do
  check_sign_in
  @shop_id = params[:shop_id]
  @products = get_shop_and_products(@shop_id)
  @page = find_page(@products)

  erb :shop, layout: :layout
end

# Edit Shop
get "/shops/:shop_id/edit" do
  check_sign_in
  @shop = get_shop
  erb :edit_shop, layout: :layout
end

post "/shops/:shop_id/edit" do
  check_sign_in
  @shop = get_shop
  if shop_name_error?
    erb :edit_shop, layout: :layout
  else
    @database.update_shop_name(params[:shop_name], @shop[:id])
    session[:success] = "#{params[:shop_name]} has been successfuly renamed"
    redirect "/shops/#{params[:shop_id]}"
  end
end

# Delete Shop
post "/shops/:shop_id/delete" do
  check_sign_in
  shop_id = params[:shop_id]
  @database.delete_shop(shop_id)
  session[:success] = "A shop has been successfuly deleted"
  redirect "/"
end

# Add new product to shop
get "/shops/:shop_id/products/new" do
  check_sign_in
  @shop = get_shop
  erb :new_product, layout: :layout
end

post "/shops/:shop_id/products/new" do
  check_sign_in
  @shop = get_shop
  shop_id = @shop[:id]

  if product_info_error?
    erb :new_product, layout: :layout
  else
    @database.add_product_to_shop(params[:product_name], params[:cost], params[:sell_price], shop_id)
    session[:success] = "#{params[:product_name]} has been successfully added to your shop"
    redirect "/shops/#{shop_id}"
  end
end

# Delete product from shop
post "/shops/:shop_id/products/:product_id/delete" do
  check_sign_in
  @database.delete_product(params[:product_id])
  session[:success] = "A product has been deleted from your shop"
  redirect "/shops/#{params[:shop_id]}"
end

# Edit Product Info
get "/shops/:shop_id/products/:product_id/edit" do
  check_sign_in
  @product = get_product
  erb :edit_product, layout: :layout
end

post "/shops/:shop_id/products/:product_id/edit" do
  check_sign_in
  if product_info_error?
    @product = get_product
    erb :edit_product, layout: :layout
  else
    @database.update_product_info(params[:product_id], params[:product_name],
                                  params[:cost], params[:sell_price])
    session[:success] = "#{params[:product_name]} has been successfully edited"
    redirect "/shops/#{params[:shop_id]}"
  end
end

# Common redirects (order important)

# To products for single shop page
get "/shops/:shop_id*" do
  redirect "/shops/#{params[:shop_id]}/page/1"
end

# To all shops page
get "/" do
  redirect "/shops/page/1"
end

get "/shops*" do
  redirect "/shops/page/1"
end

# Catch all redirect
get "/*" do
  return if request.fullpath.include?('favicon')

  register_errors("That page does not exist")
  redirect "/shops/page/1"
end
