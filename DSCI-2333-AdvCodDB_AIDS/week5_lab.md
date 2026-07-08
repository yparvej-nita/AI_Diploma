# Lab 5 Entity Relationships 

```sql
CREATE TABLE product_details (
productID INT UNSIGNED NOT NULL,
-- same data type as the parent table
comment TEXT NULL,
-- up to 64KB
PRIMARY KEY (productID),
FOREIGN KEY (productID) REFERENCES products (productID)
)
```

```sql
DESCRIBE product_details
```


```sql
SHOW CREATE TABLE product_details \G
```


```sql
DROP TABLE IF EXISTS suppliers;

CREATE TABLE suppliers (
supplierID INT UNSIGNED NOT NULL AUTO_INCREMENT,
name VARCHAR (30)NOT NULL DEFAULT '',
phone CHAR (8) NOT NULL DEFAULT '',
PRIMARY KEY (supplierID)
)3
```


```sql
DESCRIBE suppliers
```

```sql

INSERT INTO suppliers VALUE
(501, 'ABC Traders', '88881111'), 
(502, 'XYZ Company', '88882222'), 
(503, 'Q2 Corp', 88883333');
```

### Instead of deleting and re-creating the products table, we shall use "ALTER TABLE" to add a new column supplierID into the products table. 

```sql
ALTER TABLE products ADD COLUMN supplierID INT UNSIGNED NOT NULL;
```
