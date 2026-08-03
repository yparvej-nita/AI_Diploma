# LAB MANUAL: Advanced Coding, Databases for AI and Data Science



## Lab 11: Learn how to create triggers in MySQL



### Lab Overview

This lab session provides a comprehensive introduction to database triggers within a MySQL environment. Students will explore how triggers can be used to automate specific actions that occur before or after data changes. By implementing triggers on events such as **INSERT**, **UPDATE**, or **DELETE**, you will learn how to enhance database integrity and maintain automated logs of database activities .

### Learning Objectives

By the end of this lab, you will be able to:

* Understand the fundamental concept and general syntax of MySQL triggers.  
* Create triggers to automate database actions based on data events.  
* Utilize triggers to enhance data integrity and create audit logs.  
* Test and analyze trigger behavior using practical scenarios.

### Prerequisites

* Access to MySQL Workbench or a similar SQL editor.  
* A basic understanding of SQL table creation and data manipulation commands.

### 1\. Understanding Trigger Syntax

A trigger is a named database object that is associated with a table and activates when a particular event occurs for that table.  
**General Flow for Creating a Trigger:**  
CREATE TRIGGER TriggerName  
(AFTER | BEFORE) (INSERT | UPDATE | DELETE)  
ON TableName FOR EACH ROW  
BEGIN  
    \-- trigger body (the logic to execute)  
END;  
4  
Figure 1: General flow and syntax for MySQL Triggers

### 2\. Step-by-Step Lab Implementation

#### Step 1: Database and Environment Setup

The goal of this specific lab exercise is to create a trigger that automatically logs an entry in a separate table whenever a new book is added to a library database . First, create and select the working database:  
CREATE DATABASE librarydb;  
USE librarydb;  
5

#### Step 2: Create the books Table

This table will store the primary information about the books in the library.

* book\_id: A unique identifier for each book (Primary Key, Auto-Increment).  
* book\_title: The title of the book.  
* author: The author of the book.

CREATE TABLE books (  
    book\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    book\_title VARCHAR(255) NOT NULL,  
    author VARCHAR(255) NOT NULL  
);  
5

#### Step 3: Create the book\_logs Table

This table will act as an audit trail, storing logs of when new books are added.

* log\_id: A unique identifier for each log entry.  
* message: A text description containing information about the added book.  
* created\_at: A timestamp capturing exactly when the log was generated.

CREATE TABLE book\_logs (  
    log\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    message TEXT,  
    created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);  
8  
Figure 2: Empty Result Grids for books and book\_logs tables

### 3\. Creating the INSERT Trigger

Now, we will define the trigger after\_book\_insert 10\. This trigger is set to fire **AFTER** a new row is successfully **INSERTED** into the books table. It will concatenate the book details into a message and insert it into the book\_logs table.  
DELIMITER $$

CREATE TRIGGER after\_book\_insert  
AFTER INSERT ON books  
FOR EACH ROW  
BEGIN  
    INSERT INTO book\_logs (message, created\_at)  
    VALUES (CONCAT('New book added: ', NEW.book\_title, ' by ', NEW.author, ' (ID: ', NEW.book\_id, ')'), NOW());  
END$$

DELIMITER ;  

### 4\. Testing and Analyzing the Trigger

#### Task 1: Test the INSERT Trigger

To verify the trigger is working, insert a record into the books table and check the book\_logs table for an automatic entry.  
INSERT INTO books (book\_title, author)  
VALUES ('The Great Gatsby', 'F. Scott Fitzgerald');  
6  
**Expected Result:**The books table should show the new record, and the book\_logs table should automatically contain a message confirming the addition.  
Figure 3: Automatic log generation after inserting a book

#### Task 2: Implement and Test an UPDATE Trigger

This trigger logs a message whenever an existing book's details (such as title or author) are modified.  
DELIMITER $$

CREATE TRIGGER after\_book\_update  
AFTER UPDATE ON books  
FOR EACH ROW  
BEGIN  
    INSERT INTO book\_logs (message, created\_at)  
    VALUES (CONCAT('Book updated: ', NEW.book\_title, ' by ', NEW.author, ' (ID: ', NEW.book\_id, ')'), NOW());  
END$$

DELIMITER ;  
13  
**Activity:**

1. Insert a dummy record (e.g., Book Title: "dd", Author: "ddd") .  
2. Update that record (e.g., Change title "dd" to "dddd") .  
3. Query the book\_logs table to confirm that both the initial insertion and the subsequent update were logged .

Figure 4: Log table reflecting both insertion and update events

### Key Concepts and Technical Glossary

* **OLD**: Used within a trigger to reference values of a record *before* a DELETE or UPDATE Operations.  
* **NEW**: Used to reference the values of a record *after* an INSERT or UPDATE operation.  
* **CONCAT()**: A SQL function used to join multiple strings together into one.  
* **NOW()**: A function that returns the current timestamp when the database operation occurs.  
* **VALUES**: Specifies the data to be inserted into a table's columns.

### Conclusion

In this lab, you successfully created and tested MySQL triggers to automate database logging. Triggers are powerful tools for ensuring that critical events—such as data additions or modifications—are captured automatically without requiring additional code in the application layer.  


----

In MySQL, triggers are **not stored inside the table data itself**; their metadata is stored in MySQL’s system catalog, and you can view it through `INFORMATION_SCHEMA.TRIGGERS` or `SHOW TRIGGERS`. In MySQL Workbench, you usually see them under a specific table’s **Triggers** tab in the schema navigator.[1][2]

## Where to look

- **All triggers in a schema:**  
  Run `SHOW TRIGGERS;` or `SHOW TRIGGERS FROM your_db;`.[3][1]
- **Detailed trigger metadata:**  
  Query `INFORMATION_SCHEMA.TRIGGERS`.[2][1]
- **Workbench view:**  
  Expand your schema, then the table, then open **Triggers** for that table.[4][5]

## Useful queries

```sql
SHOW TRIGGERS;
```

```sql
SHOW TRIGGERS FROM your_database;
```

```sql
SELECT *
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'your_database';
```

## If you need the trigger body

Use:

```sql
SHOW CREATE TRIGGER trigger_name;
```

That returns the exact `CREATE TRIGGER` statement, including the trigger logic.

----

DROP TRIGGER librarydb.after_book_update;

To remove a trigger in MySQL, use `DROP TRIGGER`. If the trigger belongs to a specific database, include the schema name to avoid ambiguity; `IF EXISTS` is a safe option that prevents an error if the trigger is missing.

## Basic syntax

```sql
DROP TRIGGER [IF EXISTS] [schema_name.]trigger_name;
```

Example:

```sql
DROP TRIGGER IF EXISTS mydb.before_update_customer;
```

This deletes the trigger from the database, and if you drop the table the trigger belongs to, MySQL also removes its triggers automatically.[2][3]

## In MySQL Workbench

1. Open your schema.
2. Expand the table that owns the trigger.
3. Right-click the trigger and choose drop/delete, or run the `DROP TRIGGER` SQL in the query editor.  
4. Refresh the schema to confirm it is gone.

## About “update” triggers

If you mean an `UPDATE` trigger, that is just a trigger that fires on `UPDATE` events. You do **not** update the trigger with `UPDATE`; you either **drop and recreate it** with a new definition, or use `SHOW CREATE TRIGGER` to copy the old version and edit it.[3][2]

## Verify before removing

Use this to list triggers first:

```sql
SHOW TRIGGERS;
```

Or inspect the exact definition:

```sql
SHOW CREATE TRIGGER trigger_name;
```

That helps you confirm the trigger name and the table it is attached to before you remove it.[6][1]

