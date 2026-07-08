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