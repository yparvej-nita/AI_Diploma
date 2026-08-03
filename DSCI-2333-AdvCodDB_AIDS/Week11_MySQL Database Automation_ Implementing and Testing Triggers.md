# LAB MANUAL: Advanced Coding, Databases for AI and Data Science



## Lab 11: Learn how to create triggers in MySQL



### Lab Overview

This lab session provides a comprehensive introduction to database triggers within a MySQL environment 3\. Students will explore how triggers can be used to automate specific actions that occur before or after data changes 3\. By implementing triggers on events such as **INSERT**, **UPDATE**, or **DELETE**, you will learn how to enhance database integrity and maintain automated logs of database activities 3\.

### Learning Objectives

By the end of this lab, you will be able to:

* Understand the fundamental concept and general syntax of MySQL triggers 3, 4\.  
* Create triggers to automate database actions based on data events 3\.  
* Utilize triggers to enhance data integrity and create audit logs 3, 5\.  
* Test and analyze trigger behavior using practical scenarios 6, 7\.

### Prerequisites

* Access to MySQL Workbench or a similar SQL editor.  
* A basic understanding of SQL table creation and data manipulation commands.

### 1\. Understanding Trigger Syntax

A trigger is a named database object that is associated with a table and activates when a particular event occurs for that table 4\.  
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

The goal of this specific lab exercise is to create a trigger that automatically logs an entry in a separate table whenever a new book is added to a library database 5\. First, create and select the working database:  
CREATE DATABASE librarydb;  
USE librarydb;  
5

#### Step 2: Create the books Table

This table will store the primary information about the books in the library 5\.

* book\_id: A unique identifier for each book (Primary Key, Auto-Increment) 5\.  
* book\_title: The title of the book 5\.  
* author: The author of the book 5\.

CREATE TABLE books (  
    book\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    book\_title VARCHAR(255) NOT NULL,  
    author VARCHAR(255) NOT NULL  
);  
5

#### Step 3: Create the book\_logs Table

This table will act as an audit trail, storing logs of when new books are added 8\.

* log\_id: A unique identifier for each log entry 8\.  
* message: A text description containing information about the added book 8\.  
* created\_at: A timestamp capturing exactly when the log was generated 8\.

CREATE TABLE book\_logs (  
    log\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    message TEXT,  
    created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP  
);  
8  
Figure 2: Empty Result Grids for books and book\_logs tables

### 3\. Creating the INSERT Trigger

Now, we will define the trigger after\_book\_insert 10\. This trigger is set to fire **AFTER** a new row is successfully **INSERTED** into the books table 10\. It will concatenate the book details into a message and insert it into the book\_logs table 10\.  
DELIMITER $$

CREATE TRIGGER after\_book\_insert  
AFTER INSERT ON books  
FOR EACH ROW  
BEGIN  
    INSERT INTO book\_logs (message, created\_at)  
    VALUES (CONCAT('New book added: ', NEW.book\_title, ' by ', NEW.author, ' (ID: ', NEW.book\_id, ')'), NOW());  
END$$

DELIMITER ;  
10, 11

### 4\. Testing and Analyzing the Trigger

#### Task 1: Test the INSERT Trigger

To verify the trigger is working, insert a record into the books table and check the book\_logs table for an automatic entry 6\.  
INSERT INTO books (book\_title, author)  
VALUES ('The Great Gatsby', 'F. Scott Fitzgerald');  
6  
**Expected Result:**The books table should show the new record, and the book\_logs table should automatically contain a message confirming the addition 6, 12\.  
Figure 3: Automatic log generation after inserting a book

#### Task 2: Implement and Test an UPDATE Trigger

This trigger logs a message whenever an existing book's details (such as title or author) are modified 13\.  
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

1. Insert a dummy record (e.g., Book Title: "dd", Author: "ddd") 7\.  
2. Update that record (e.g., Change title "dd" to "dddd") 7\.  
3. Query the book\_logs table to confirm that both the initial insertion and the subsequent update were logged 7\.

Figure 4: Log table reflecting both insertion and update events

### Key Concepts and Technical Glossary

* **OLD**: Used within a trigger to reference values of a record *before* a DELETE or UPDATE operation 11\.  
* **NEW**: Used to reference the values of a record *after* an INSERT or UPDATE operation 11\.  
* **CONCAT()**: A SQL function used to join multiple strings together into one 11\.  
* **NOW()**: A function that returns the current timestamp when the database operation occurs 11\.  
* **VALUES**: Specifies the data to be inserted into a table's columns 11\.

### Conclusion

In this lab, you successfully created and tested MySQL triggers to automate database logging 3, 7\. Triggers are powerful tools for ensuring that critical events—such as data additions or modifications—are captured automatically without requiring additional code in the application layer 3\.  
NITA Footer Logo  
**Thank You \- National Information Technology Academy** 15  
