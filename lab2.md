
```sql
CREATE DATABASE s_records1;
SHOW DATABASES; 
USE s_records1;
SHOW TABLES;

```

---
```sql
CREATE DATABASE southwind;
SHOW DATABASES; 
USE southwind;
SHOW TABLES;
```
  
```sql
-- Set "southwind" as the default databe 
USE southwind;
-- Show the current (default) database
SELECT DATABASE();
```
---

```sql
-- Create the table "products". Read "explanations" below for the column definitions 
CREATE TABLE IF NOT EXISTS products (
    productID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    productCode CHAR(3) NOT NULL DEFAULT '',
    name VARCHAR(30) NOT NULL DEFAULT '',
    quantity INT UNSIGNED NOT NULL DEFAULT 0,
    price DECIMAL(7,2) NOT NULL DEFAULT 99999.99,
    PRIMARY KEY (productID)
);

```

```sql
-- Show all the tables to confirm that the "products" table has been created
SHOW TABLES;
```


---

# Lab 2

## Insert a row with all the column values

```sql
INSERT INTO products VALUES (1001, "PEN', "Pen Red', 5000, 1.23);

```

## Insert multiple rows in one command

```sql
-- Insert multiple rows in one command
-- Inserting NULL to the auto_increment column results in max_value + 1
INSERT INTO products VALUES
(NULL, 'PEN", "Pen Blue", 8000, 1.25),
(NULL, 'PEN", "Pen Black', 2000, 1.25);

```
## Inserting values to certain columns…(1)

-- ﻿﻿Insert value to selected columns
-- Missing value for the auto_increment column also results in max_value+1 

```sql
INSERT INTO products (productCode, name, quantity, price) VALUES  
    ('PEC', 'Pencil 28', 10000, 0.48), 
    ('PEC', 'Pencil 2H', 8000, 0.49);

```
## Inserting values to certain columns…(2)

-- Missing columns set their default values

```sql
INSERT INTO products (productCode, name) VALUES ('PEC', 'Pencil HD");
```

## Viewing the contents of the table

```sql
SELECT * from PRODUCTS;
```

----

# How to query the data and various techniques involved

Initialize the use of the database southwind
```sql
SHOW DATABASES;
-- Set "southwind" as the default database
USE southwind;
-- SHow the current (default) database
SELECT DATABASES();

```

## Check for the table as follows:
```sql
SHOW TABLES;
```

## List all rows of ALL the columns -Select using wildcard * (asterix)
```sql
-- List all rows of ALL the columns. The wildcard * denotes ALL columns 
SELECT * FROM products;
```

## Select certain columns

```sql
-- List all rows for the specified columns 
SELECT name, price FROM products;
```

---
# LAB3
SELECT * FROM products WHERE quantity >= 5000 AND name LIKE 'Pen %';

----

```sql
SELECT * FROM products WHERE NOT (quantity >= 5000 AND name LIKE 'Pen %');
```
```sql
SELECT * FROM products WHERE quantity >= 5000 AND price < 1.24 AND name LIKE 'Pen %';
```

```sql
SELECT * FROM products WHERE name IN ('Pen Red', 'Pen Black');
```

```sql
SELECT * FROM products WHERE (price BETWEEN 1.0 AND 2.0) AND (quantity BETWEEN 1000 AND 2000);
```

```sql
SELECT productID, name, price + 0.05 AS new_price FROM products;

```

```
SELECT productID, name, quantity - 500 AS remaining_quantity
```

---
## Lab 3: ORDER BY and GROUP BY

```sql
SELECT * FROM product NHERE name LIKE 'Pen %' ORDER BY price DESC;
```

### Order by price in descending order, followed by quantity in ascending (default) order

```
SELECT * FROM product NHERE name LIKE 'Pen %' ORDER BY price DESC, quantity;
```


### Display the first two rows
 
```
SELECT * FROM products ORDER BY price LIMIT 2:
```

