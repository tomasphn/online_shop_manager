CREATE DATABASE shops;      --Creates and connects to shop database
\connect shops;

CREATE TABLE shops (
  id serial PRIMARY KEY,
  name varchar(35) NOT NULL
);

CREATE TABLE products (
  id serial PRIMARY KEY,
  name varchar(35) NOT NULL,
  cost decimal(7, 2) NOT NULL,
  sell_price decimal (7, 2) NOT NULL,
  shop_id integer NOT NULL REFERENCES shops (id)
);

INSERT INTO shops (name)
     VALUES ('Toy Shop'), 
            ('Jewlery Shop'), 
            ('Clothes Shop'),
            ('Game Shop'), 
            ('Food Shop'), 
            ('Card Shop'),
            ('Shoes Shop'), 
            ('Empty Shop');

INSERT INTO products (name, cost, sell_price, shop_id)
              VALUES ('Racecar', 1.50, 5, 1),         --Toy shop products
                     ('Doll', 3, 8.25, 1),
                     ('Action Figure', 3, 7.50, 1),
                     ('Ball', 1, 5, 1),
                     ('Bat', 4, 6, 1),
                     ('Fidget', 0.5, 3, 1),
                     ('Dominoes', 2, 4.75, 1),
                     ('Jacks', 0.25, 1.50, 1),
                     ('Marbles', 0.75, 1.50, 1),
                     ('Jump Rope', 5, 10, 1),
                     ('Watch', 15, 25.50, 2),         --Jewlery Shop products
                     ('Earrings', 2.50, 7.50, 2),
                     ('Bracelet', 8, 17.50, 2),
                     ('Necklace', 10, 40, 2),
                     ('Hoops', 2, 10, 2),
                     ('Diamond Ring', 100, 200, 2),
                     ('Gold Ring', 80, 170, 2),
                     ('Shirt', 3, 15.50, 3),         --Clothes Shop products
                     ('Hoodie', 8, 22.50, 3),
                     ('Jeans', 7.50, 20, 3),
                     ('Overalls', 10, 32.25, 3),
                     ('Raincoat', 12, 37.50, 3),
                     ('Monopoly', 7.50, 15, 4),         --Game Shop products
                     ('Sorry', 6, 12.50, 4),
                     ('Shoots and Ladders', 5.25, 10, 4),
                     ('Chess', 5, 10, 4),
                     ('Apple', 0.25, 1.25, 5),         --Food Shop products
                     ('Carrot', 0.40, 1, 5),
                     ('Ace', 1, 17, 6),         --Card Shop products
                     ('Jordans', 15, 60, 7);         --Shoes Shop products
