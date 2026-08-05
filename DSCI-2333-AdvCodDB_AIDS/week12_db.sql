CREATE DATABASE CompanyDB;  
USE CompanyDB;
CREATE TABLE Employees (  
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,  
    Name VARCHAR(100) NOT NULL,  
    Salary DECIMAL(10, 2) NOT NULL,  
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP  
);

DELIMITER $$
CREATE TRIGGER BeforeInsertEmployee  
BEFORE INSERT ON Employees  
FOR EACH ROW  
BEGIN  
    IF NEW.Salary < 3000 THEN  
        SET NEW.Salary = 3000;  
    END IF;  
END$$

DELIMITER ;

-- Insert a valid salary  
INSERT INTO Employees (Name, Salary) VALUES ('Alice', 4000);  
SELECT * FROM Employees;

-- Insert a salary below the threshold  
INSERT INTO Employees (Name, Salary) VALUES ('Bob', 2500);  
SELECT * FROM Employees; 


-- Part 2: Audit Logging with AFTER Triggers

CREATE TABLE customers (  
    customer_id INT AUTO_INCREMENT PRIMARY KEY,  
    name VARCHAR(50)  
);

CREATE TABLE orders (  
    order_id INT AUTO_INCREMENT PRIMARY KEY,  
    customer_id INT,  
    drink VARCHAR(50),  
    order_time DATETIME  
);

CREATE TABLE order_log (  
    log_id INT AUTO_INCREMENT PRIMARY KEY,  
    customer_id INT,  
    drink VARCHAR(50),  
    action_time DATETIME,  
    action VARCHAR(50)  
);

#### A. Log Order Placement (AFTER INSERT)

DELIMITER $$

CREATE TRIGGER log_order  
AFTER INSERT  
ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order_log (customer_id, drink, action_time, action)  
    VALUES (NEW.customer_id, NEW.drink, NOW(), 'Ordered');  
END$$
DELIMITER ;

#### B. Log Order Updates (AFTER UPDATE)

DELIMITER $$

CREATE TRIGGER log_update_order  
AFTER UPDATE  
ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order_log (customer_id, drink, action_time, action)  
    VALUES (NEW.customer_id, NEW.drink, NOW(), 'Updated');  
END$$ 
DELIMITER ;

#### C. Log Order Cancellations (AFTER DELETE)

DELIMITER $$
CREATE TRIGGER log_delete_order  
AFTER DELETE  
ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order_log (customer_id, drink, action_time, action)  
    VALUES (OLD.customer_id, OLD.drink, NOW(), 'Deleted');  
END$$ 
DELIMITER ;

-- 4 Testing the Audit System

-- Test the logging mechanism by performing various DML operations  
-- Test Insert  
INSERT INTO orders (customer_id, drink, order_time)  
VALUES (1, 'Mystic Mocha', NOW());

-- Test Multiple Inserts  
INSERT INTO orders (customer_id, drink, order_time)  
VALUES (2, 'Dragon Latte', NOW()), (3, 'Phoenix Frappuccino', NOW());

-- Test Update  
UPDATE orders SET drink = 'Celestial Cappuccino' WHERE order_id = 1;

-- Test Delete  
DELETE FROM orders WHERE order_id = 1;

-- Verify the log  
SELECT * FROM order_log;



--  Part 3: Comprehensive E-commerce Application

###1 Schema Design

-- In this final task, you will build a more complex e-commerce structure including users, products, orders, and a consolidated order\_history table  
CREATE TABLE users (  
    user_id INT AUTO_INCREMENT PRIMARY KEY,  
    username VARCHAR(50) NOT NULL,  
    email VARCHAR(100) NOT NULL  
);

CREATE TABLE products (  
    product_id INT AUTO_INCREMENT PRIMARY KEY,  
    product_name VARCHAR(100) NOT NULL,  
    price DECIMAL(10, 2) NOT NULL  
);

CREATE TABLE orders (  
    order_id INT AUTO_INCREMENT PRIMARY KEY,  
    user_id INT NOT NULL,  
    product_id INT NOT NULL,  
    order_time DATETIME NOT NULL DEFAULT NOW(),  
    FOREIGN KEY (user_id) REFERENCES users(user_id),  
    FOREIGN KEY (product_id) REFERENCES products(product_id)  
);

CREATE TABLE order_history (  
    history_id INT AUTO_INCREMENT PRIMARY KEY,  
    user_id INT NOT NULL,  
    product_id INT NOT NULL,  
    action_time DATETIME NOT NULL,  
    action VARCHAR(50) NOT NULL,  
    FOREIGN KEY (user_id) REFERENCES users(user_id),  
    FOREIGN KEY (product_id) REFERENCES products(product_id)  
);

###2 Task: Build the Comprehensive Trigger Suite

-- Implement the logic to automatically populate order\_history based on events in the orders table  
-- Order Placement History  
DELIMITER $$ 
CREATE TRIGGER log_order_placement  
AFTER INSERT ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order_history (user_id, product_id, action_time, action)  
    VALUES (NEW.user_id, NEW.product_id, NOW(), 'Order Placed');  
END$$ 

-- Order Update History  
CREATE TRIGGER log_order_update  
AFTER UPDATE ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order_history (user_id, product_id, action_time, action)  
    VALUES (NEW.user_id, NEW.product_id, NOW(), 'Order Updated');  
END$$ 

-- Order Cancellation History  
CREATE TRIGGER log_order_delete  
AFTER DELETE ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order_history (user_id, product_id, action_time, action)  
    VALUES (OLD.user_id, OLD.product_id, NOW(), 'Order Cancelled');  
END$$ 
DELIMITER ;


###3 Final Testing

-- Execute the following commands to populate users and test the history tracking  
-- Add initial data  
INSERT INTO users (username, email) VALUES ('Alice', 'alice@example.com'), ('Bob', 'bob@example.com');

-- Delete an order to test cancellation logging  
DELETE FROM orders WHERE order_id= 2;

-- Verify full history  
SELECT * FROM order_history;
