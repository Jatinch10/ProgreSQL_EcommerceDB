CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('customer', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    street_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT REFERENCES categories(category_id),
    stock_quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled')) NOT NULL
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) CHECK (payment_method IN ('credit_card', 'paypal', 'bank_transfer')) NOT NULL,
    payment_status VARCHAR(50) CHECK (payment_status IN ('pending', 'completed', 'failed')) NOT NULL
);

CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    shipment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tracking_number VARCHAR(255),
    carrier VARCHAR(100) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'shipped', 'delivered', 'returned')) NOT NULL
);

CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    user_id INT REFERENCES users(user_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory_logs (
    log_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    change_quantity INT,
    change_type VARCHAR(50) CHECK (change_type IN ('restock', 'order')),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_orders_user_id ON orders(user_id);

CREATE OR REPLACE FUNCTION update_stock() 
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_stock();

CREATE OR REPLACE FUNCTION generate_customer_report(input_user_id INT)
RETURNS TABLE(order_id INT, order_date TIMESTAMP, total_amount DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT o.order_id, o.order_date, o.total_amount
    FROM orders o
    WHERE o.user_id = input_user_id;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW order_details AS
SELECT o.order_id, o.order_date, o.total_amount, oi.quantity, oi.price, p.name AS product_name
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Insert categories
INSERT INTO categories (category_name) VALUES 
('Electronics'), 
('Clothing'), 
('Home & Kitchen'), 
('Books');

-- Insert products
INSERT INTO products (name, description, price, category_id, stock_quantity) VALUES 
('Laptop', 'High performance laptop', 999.99, 1, 50),
('T-shirt', 'Cotton T-shirt', 19.99, 2, 200),
('Blender', 'Kitchen blender for smoothies', 49.99, 3, 30),
('Novel', 'A thrilling novel', 12.99, 4, 100);

-- Insert users
INSERT INTO users (username, email, password_hash, full_name, role) VALUES 
('john_doe', 'john@example.com', 'hashedpassword1', 'John Doe', 'customer'),
('admin_user', 'admin@example.com', 'hashedpassword2', 'Admin User', 'admin');

-- Insert orders
INSERT INTO orders (user_id, total_amount, status) VALUES
(1, 123.45, 'pending'),
(1, 56.78, 'shipped');

-- Insert order_items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 999.99),
(2, 2, 3, 19.99);

-- Insert payments
INSERT INTO payments (order_id, amount, payment_method, payment_status) VALUES 
(1, 123.45, 'credit_card', 'completed'),
(2, 59.97, 'paypal', 'pending');

SELECT * FROM users WHERE username = 'john_doe';

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 999.99);
-- Check if the stock quantity is updated for the product
SELECT * FROM products WHERE product_id = 1;

SELECT * FROM order_details;

SELECT * FROM generate_customer_report(1);



