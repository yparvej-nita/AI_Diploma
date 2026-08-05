# Week 12 - Lab 12: Advanced Database Triggers

## Lab Overview

This laboratory session focuses on the implementation and management of **database triggers** within a MySQL environment Triggers are automated stored programs that execute in response to specific events on a particular table, such as INSERT, UPDATE, or DELETE operations Students will learn how to use these tools to automate data validation, maintain audit logs, and enforce complex business rules directly within the database layer

## Learning Objectives

By the end of this lab, students should be able to:

* Understand the fundamental purpose and utility of database triggers  
* Differentiate between **BEFORE** and **AFTER** triggers  
* Successfully create and test MySQL triggers for various data events  
* Enhance database integrity by executing automated logic during data modification  
* Apply trigger logic to real-world scenarios, such as e-commerce logging and employee data validation

## Prerequisites

To complete this lab, you will need:

* A functional MySQL Server installation.  
* A database client (e.g., MySQL Workbench or Command Line Client).  
* Basic knowledge of SQL Data Definition Language (DDL) and Data Manipulation Language (DML).

## Part 1: Understanding and Implementing BEFORE Triggers

###1 Introduction to BEFORE Triggers

In MySQL, **BEFORE triggers** are used to execute logic *before* a change is applied to a table They are particularly useful for:

* **Data Validation:** Checking if data meets specific criteria before it is saved  
* **Automatic Modification:** Formatting or adjusting values before they are written to the disk  
* **Business Rule Enforcement:** Ensuring all changes comply with organizational policies

###2 Environment Setup

First, create a new database and a sample table to store employee information  

```sql
CREATE DATABASE CompanyDB;  
USE CompanyDB;
CREATE TABLE Employees (  
    EmployeeID INT AUTO\_INCREMENT PRIMARY KEY,  
    Name VARCHAR(100) NOT NULL,  
    Salary DECIMAL(10, 2\) NOT NULL,  
    CreatedAt TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);

```

###3 Task: Creating a BEFORE INSERT Trigger

This task involves creating a trigger that ensures no employee is entered into the system with a salary below a minimum threshold of $3000 If a lower salary is provided, the trigger will automatically adjust it to the minimum  
DELIMITER //

CREATE TRIGGER BeforeInsertEmployee  
BEFORE INSERT ON Employees  
FOR EACH ROW  
BEGIN  
    IF NEW.Salary \< 3000 THEN  
        SET NEW.Salary \= 3000;  
    END IF;  
END;

//  
DELIMITER ;

###4 Testing the Trigger

To verify the trigger, insert two records: one that meets the salary requirement and one that does not  
\-- Insert a valid salary  
INSERT INTO Employees (Name, Salary) VALUES ('Alice', 4000);  
SELECT \* FROM Employees;

\-- Insert a salary below the threshold  
INSERT INTO Employees (Name, Salary) VALUES ('Bob', 2500);  
SELECT \* FROM Employees;  
**Expected Results:**As shown in the following figure, Bob's salary is automatically adjusted to00 upon insertion  
Figure 1: Result Grid showing the automatic salary adjustment for Bob from 2500 to 3000*Caption: Result Grid showing the successful execution of the BeforeInsertEmployee trigger*

## Part 2: Audit Logging with AFTER Triggers

###1 Scenario Overview

In this section, we will create a system to log every action (Insert, Update, Delete) performed on an orders table This is a common requirement for maintaining a history of database changes.

###2 Setup Tables

Execute the following code to set up the necessary customer, order, and log tables  
CREATE TABLE customers (  
    customer\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    name VARCHAR(50)  
);

CREATE TABLE orders (  
    order\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    customer\_id INT,  
    drink VARCHAR(50),  
    order\_time DATETIME  
);

CREATE TABLE order\_log (  
    log\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    customer\_id INT,  
    drink VARCHAR(50),  
    action\_time DATETIME,  
    action VARCHAR(50)  
);

###3 Task: Implementing Logging Triggers

Create triggers to capture all phases of an order's lifecycle

#### A. Log Order Placement (AFTER INSERT)

DELIMITER //

CREATE TRIGGER log\_order  
AFTER INSERT  
ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order\_log (customer\_id, drink, action\_time, action)  
    VALUES (NEW.customer\_id, NEW.drink, NOW(), 'Ordered');  
END;

//  
DELIMITER ;

#### B. Log Order Updates (AFTER UPDATE)

DELIMITER //

CREATE TRIGGER log\_update\_order  
AFTER UPDATE  
ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order\_log (customer\_id, drink, action\_time, action)  
    VALUES (NEW.customer\_id, NEW.drink, NOW(), 'Updated');  
END;

//  
DELIMITER ;

#### C. Log Order Cancellations (AFTER DELETE)

DELIMITER //

CREATE TRIGGER log\_delete\_order  
AFTER DELETE  
ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order\_log (customer\_id, drink, action\_time, action)  
    VALUES (OLD.customer\_id, OLD.drink, NOW(), 'Deleted');  
END;

//  
DELIMITER ;

###4 Testing the Audit System

Test the logging mechanism by performing various DML operations  
\-- Test Insert  
INSERT INTO orders (customer\_id, drink, order\_time)  
VALUES (1, 'Mystic Mocha', NOW());

\-- Test Multiple Inserts  
INSERT INTO orders (customer\_id, drink, order\_time)  
VALUES (2, 'Dragon Latte', NOW()), (3, 'Phoenix Frappuccino', NOW());

\-- Test Update  
UPDATE orders SET drink \= 'Celestial Cappuccino' WHERE order\_id \= 1;

\-- Test Delete  
DELETE FROM orders WHERE order\_id \= 1;

\-- Verify the log  
SELECT \* FROM order\_log;

## Part 3: Comprehensive E-commerce Application

###1 Schema Design

In this final task, you will build a more complex e-commerce structure including users, products, orders, and a consolidated order\_history table  
CREATE TABLE users (  
    user\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    username VARCHAR(50) NOT NULL,  
    email VARCHAR(100) NOT NULL  
);

CREATE TABLE products (  
    product\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    product\_name VARCHAR(100) NOT NULL,  
    price DECIMAL(10, 2\) NOT NULL  
);

CREATE TABLE orders (  
    order\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    user\_id INT NOT NULL,  
    product\_id INT NOT NULL,  
    order\_time DATETIME NOT NULL DEFAULT NOW(),  
    FOREIGN KEY (user\_id) REFERENCES users(user\_id),  
    FOREIGN KEY (product\_id) REFERENCES products(product\_id)  
);

CREATE TABLE order\_history (  
    history\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    user\_id INT NOT NULL,  
    product\_id INT NOT NULL,  
    action\_time DATETIME NOT NULL,  
    action VARCHAR(50) NOT NULL,  
    FOREIGN KEY (user\_id) REFERENCES users(user\_id),  
    FOREIGN KEY (product\_id) REFERENCES products(product\_id)  
);

###2 Task: Build the Comprehensive Trigger Suite

Implement the logic to automatically populate order\_history based on events in the orders table  
\-- Order Placement History  
DELIMITER //  
CREATE TRIGGER log\_order\_placement  
AFTER INSERT ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order\_history (user\_id, product\_id, action\_time, action)  
    VALUES (NEW.user\_id, NEW.product\_id, NOW(), 'Order Placed');  
END;  
//

\-- Order Update History  
CREATE TRIGGER log\_order\_update  
AFTER UPDATE ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order\_history (user\_id, product\_id, action\_time, action)  
    VALUES (NEW.user\_id, NEW.product\_id, NOW(), 'Order Updated');  
END;  
//

\-- Order Cancellation History  
CREATE TRIGGER log\_order\_delete  
AFTER DELETE ON orders  
FOR EACH ROW  
BEGIN  
    INSERT INTO order\_history (user\_id, product\_id, action\_time, action)  
    VALUES (OLD.user\_id, OLD.product\_id, NOW(), 'Order Cancelled');  
END;  
//  
DELIMITER ;

###3 Final Testing

Execute the following commands to populate users and test the history tracking  
\-- Add initial data  
INSERT INTO users (username, email) VALUES ('Alice', 'alice@example.com'), ('Bob', 'bob@example.com');

\-- Delete an order to test cancellation logging  
DELETE FROM orders WHERE order\_id \= 2;

\-- Verify full history  
SELECT \* FROM order\_history;

## Additional Exercise: Logging Deletions in a Library System

In a library scenario, when a book is deleted from the books table, you must log the details including the title, author, and book ID  
Figure 2: Example books table content prior to deletion*Caption: Initial state of the books table*  
**Task:** Write a trigger to log book deletions into a table named book\_logs  
DELIMITER $$

CREATE TRIGGER after\_book\_delete  
AFTER DELETE ON books  
FOR EACH ROW  
BEGIN  
    INSERT INTO book\_logs (message, created\_at)  
    VALUES (CONCAT('Book deleted: ', OLD.book\_title, ' by ', OLD.author, ' (ID: ', OLD.book\_id, ')'), NOW());  
END$$

DELIMITER ;

## Conclusion

In this lab, you explored the power of MySQL triggers to automate database management tasks You successfully implemented **BEFORE** triggers for data validation and **AFTER** triggers for complex audit logging across multiple scenarios These skills are essential for ensuring data integrity and creating robust, self-managing database systems in professional environments.  
