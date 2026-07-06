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