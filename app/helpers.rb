require "sinatra"

# View Helper methods
helpers do
  # Returns items within array on a certain page (5 items per page)
  def items_on_page_n(items, page)
    return [] if items[0][:id].nil?

    start_indx = ((page[:current] - 1) * 5)
    end_indx = start_indx + 4
    if page[:current] == page[:total]
      items[start_indx..-1]
    else
      items[start_indx..end_indx]
    end
  end

  # Checks if a next/previous page button should be generated
  def more_pages?(page)
    page[:current] < page[:total]
  end

  def less_pages?(page)
    page[:current] > 1
  end

  # Generates content for "profit" field for products
  def find_profit(cost, price)
    '%.2f' % (price.to_f - cost.to_f)
  end

  def profit_class(product)
    profit = find_profit(product[:cost], product[:sell_price]).to_f
    if profit > 10
      "high_profit"
    elsif profit < 5
      "low_profit"
    else
      "medium_profit"
    end
  end
end

# Other helpers

# Checks if user signed in
def user_signed_in?
  session.key?(:signin)
end

# Checks sign in, saves path + redirects if not
def check_sign_in
  return if user_signed_in?

  session[:next_path] = request.fullpath
  register_errors("You must be signed in to view or edit the database")
  redirect "/signin"
end

# Checks username and password against list of registered users
def valid_user?(user, pass)
  key = user.to_sym
  logins = { admin: "secret", guest: "pass" }
  logins[key] == pass
end

# Register session error(can handle multiple)
def register_errors(*errors)
  return if errors.empty?

  if session[:errors]
    all_errors = session[:errors].concat(errors)
    session[:errors] = all_errors
  else
    session[:errors] = errors
  end
end

# User input validation methods
def shop_name_error?
  name = params[:shop_name].strip
  register_errors("Shop name must be between 1 and 35 characters") unless (1..35).cover?(name.size)
end

def product_info_error?
  cost_error?
  price_error?
  product_name_error?
  session[:errors]
end

def cost_error?
  cost = params[:cost].to_f
  if !(0.01..9999.99).cover?(cost) || over_two_decimals?(cost)
    params[:cost] = nil
    register_errors("Product cost must be a valid dollar amount between 0.01 and 9999.99")
  end
end

def price_error?
  price = params[:sell_price].to_f
  if !(0.01..9999.99).cover?(price) || over_two_decimals?(price)
    params[:sell_price] = nil
    register_errors("Product price must be a valid dollar amount between 0.01 and 9999.99")
  end
end

def product_name_error?
  name = params[:product_name].strip
  if !(1..35).cover?(name.size)
    params[:product_name] = nil
    register_errors( "Your product name must be between 1 and 35 characters")
  end
end

# Retrieval methods that validate results before returning
def get_shop
  return unless valid_id?(params[:shop_id])

  shop = @database.find_shop(params[:shop_id])
  return shop if valid_shop?(shop)
end

def get_product
  return unless valid_id?(params[:product_id])

  product = @database.find_product(params[:product_id])
  return product if valid_product?(product)
end

def get_shop_and_products(shop_id)
  return unless valid_id?(shop_id)

  shop = @database.shop_and_products(shop_id)
  return shop if valid_shop?(shop)
end

def find_page(items)
  return unless valid_id?(params[:page])

  total_pages = (items.count.to_f / 5).ceil
  current_page = params[:page].to_i || 1

  page = { current: current_page, total: total_pages }
  return page if valid_page?(page)
end

# Id/page validation helpers
def valid_id?(id)
  return true if integer?(id)

  register_errors("#{id} is not a valid id or page number")
  redirect "/shops/page/1"
end

def valid_page?(page)
  return true if (1..page[:total]).cover?(page[:current]) || page[:total] == 0

  register_errors("That page does not exist")
  redirect "/shops/page/1"
end

def valid_shop?(shop)
  return true unless invalid_result?(shop)

  register_errors("That shop id does not exist")
  redirect "/shops/page/1"
end

def valid_product?(product)
  return true unless invalid_result?(product)

  register_errors("That product id does not exist")
  redirect "/shops/page/1"
end

def invalid_result?(result)
  result.nil? || result.empty?
end

# Misc
def over_two_decimals?(num)
  string = num.to_s
  return false unless string.include?(".")

  decimals = string.split(".").last.size
  decimals > 2
end

def integer?(num)
  !(num =~ /[^0-9]/)
end
