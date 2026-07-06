## AS Keyword

```sql
-- Define aliases to be used as display names
SELECT productID AS ID, productCode AS Code, name AS Description, price AS 'Unit Price'  FROM products ORDER BY ID;
```

```sql
SELECT CONCAT('Hello', COALESCE(NULL, ''), 'World') AS result;
``````

```sql
SELECT CONCAT('Hello', COALESCE(NULL, ''), 'World') AS result;
```

```sql
select concat(productCode, '-',name) as 'productdescription', price from  products; 

```

```sql
select distinct price as 'Distinct price' from products;
```

```sql

select distinct price,name as 'Distinct price name' from products;

```

```sql
SELECT COUNT(*) AS 'Count' FROM products;
```

```sql
SELECT productCode, COUNT(*) AS 'Count' FROM products GROUP BY productCode;
```

```sql
SELECT
    MAX(price),
    MIN(price),
    AVG(price),
    STD(price),
    SUM(quantity)
FROM products;
-- Without GROUP BY - All rows
```

```sql
SELECT
    productCode,
    MAX(price) AS 'Highest Price',
    MIN(price) AS 'Lowest Price'
FROM products
GROUP BY productCode;
```

```sql
SELECT
    productCode,
    MAX(price),
    MIN(price),
    CAST(AVG(price) AS DECIMAL(7,2)) AS 'Average',
    CAST(STD(price) AS DECIMAL(7,2)) AS 'Std Dev',
    SUM(quantity)
FROM products
GROUP BY productCode;
-- Use CAST(... AS ...) function to format floating-point numbers
```

```sql
SELECT
    productCode AS 'Product Code',
    COUNT(*) AS 'Count',
    CAST(AVG(price) AS DECIMAL(7,2)) AS 'Average'
FROM products
GROUP BY productCode
HAVING COUNT(*) >= 3;
-- CANNOT use WHERE count >= 3
```

```sql
SELECT
    productCode,
    MAX(price),
    MIN(price),
    CAST(AVG(price) AS DECIMAL(7,2)) AS 'Average',
    SUM(quantity)
FROM products
GROUP BY productCode
WITH ROLLUP;
-- Apply aggregate functions to all groups
```


```sql
SHOW DATABASES;
USE southwind;
SELECT DATABASE();
```

-- Increase the price by 10% for all products

```sql

UPDATE products
SET price = price * 1.1;
SELECT * FROM products;
```

-- Modify selected rows

```sql
UPDATE products
SET quantity = quantity - 100
WHERE name = 'Pen Red';
```

```sql
SELECT * FROM products WHERE name = 'Pen Red';

```

-- You can modify more than one value

```sql
UPDATE products SET quantity = quantity + 50, price = 1.23 WHERE name = 'Pen Red';
```

```sql

SELECT * FROM products WHERE name = 'Pen Red';

```sql
-- Delete all rows from the table. Use with extreme care! Records are NOT recoverable!!!
DELETE FROM tableName;
```

```sql
-- Delete only row(s) that meet the criteria
DELETE FROM tableName
WHERE criteria;
```

```sql
DELETE FROM products WHERE name LIKE 'Pencil%';
SELECT * FROM products;
```

-- Use this with extreme care, as the deleted records are irrecoverable!
```sql
DELETE FROM products;
```

```sql
SELECT * FROM products;

