require "pg"

class ShopDatabase
  def initialize(logger)
    @db = PG.connect(dbname: "shops")
    @logger = logger
  end

  # Execute Sql queries safely
  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  # Create a new shop
  def create_new_shop(shop_name)
    sql = "INSERT INTO shops (name) VALUES ($1)"
    query(sql, shop_name)
  end

  # Create new product within shop
  def add_product_to_shop(name, cost, sell_price, shop_id)
    sql = "INSERT INTO products (name, cost, sell_price, shop_id) VALUES ($1, $2, $3, $4)"
    query(sql, name, cost, sell_price, shop_id)
  end

  # Return all shops ordered by product count and alphabetically
  def all_shops
    sql = <<~SQL
            SELECT shops.*, count(products.id) AS product_count
            FROM shops LEFT JOIN products
            ON shops.id = products.shop_id
            GROUP BY shops.id
            ORDER BY product_count DESC, lower(shops.name)
          SQL
    result = query(sql)
    format_result(result)
  end

  # Return single shop hash
  def find_shop(shop_id)
    sql = "SELECT * FROM shops WHERE id = $1"
    result = query(sql, shop_id)
    format_result(result, single = true)
  end

  # Return array of products belonging to shop, ordered by profit
  def shop_and_products(shop_id)
    sql = <<~SQL
            SELECT products.*, shops.name AS shop_name, shops.id AS shop_id
            FROM products RIGHT JOIN shops
            ON products.shop_id = shops.id
            WHERE shops.id = $1
            ORDER BY (sell_price - cost) DESC
          SQL
    result = query(sql, shop_id)
    format_result(result)
  end

  # Return single product hash
  def find_product(product_id)
    sql = "SELECT * FROM products WHERE id = $1"
    result = query(sql, product_id)
    format_result(result, single = true)
  end

  # Update shop name
  def update_shop_name(new_name, shop_id)
    sql = "UPDATE shops SET name = $1 WHERE id = $2"
    query(sql, new_name, shop_id)
  end

  # Update product info
  def update_product_info(id, name, cost, sell_price)
    sql = <<~SQL
            UPDATE products 
            SET name = $2, cost = $3, sell_price = $4
            WHERE id = $1
          SQL
    query(sql, id, name, cost, sell_price)
  end

  # Delete shop and associated products
  def delete_shop(shop_id)
    sql = "DELETE FROM products WHERE shop_id = $1"
    query(sql, shop_id)

    sql2 = "DELETE FROM shops WHERE id = $1"
    query(sql2, shop_id)
  end

  # Delete product
  def delete_product(product_id)
    sql = "DELETE FROM products WHERE id = $1"
    query(sql, product_id)
  end

  private

  # Return result object formatted as an array of hashes (or single hash if single = true)
  def format_result(result, single = false)
    formatted = result.map do |tuple|
      result.fields.each_with_object({}) do |field, hash|
        hash[field.to_sym] = tuple[field]
      end
    end

    return formatted unless single == true

    formatted[0]
  end
end
