# LAB MANUAL: Advanced Coding, Databases for AI and Data Science

## Lab 9: Mastering Functions in MySQL Workbench

### 1\. Lab Overview

This lab focuses on the fundamental concepts and practical implementation of user-defined functions within the **MySQL Workbench** environment 1\. Functions are essential database tools that allow for code encapsulation, reusability, and complex data transformations directly within the database engine 1\.

### 2\. Learning Objectives

By the end of this lab session, you will be able to:

* Navigate MySQL Workbench to create and manage custom functions.  
* Understand and apply the basic syntax for creating MySQL functions 1\.  
* Effectively use delimiters to define multi-line function blocks 1\.  
* Select appropriate function characteristics (e.g., DETERMINISTIC) based on the logic required 1\.  
* Write and execute various custom functions, including mathematical calculations and conditional logic 1\.

### 3\. Prerequisites

* **MySQL Workbench** installed and connected to a running MySQL server instance.  
* Basic understanding of SQL data types (INT, DECIMAL, VARCHAR) 1\.

### 4\. Step-by-Step Instructions for MySQL Workbench

#### Task 1: Setting Up Your Workspace

1. Launch **MySQL Workbench** and open your database connection.  
2. In the **Navigator** pane, ensure you have selected the schema (database) where you want to create your functions.  
3. Open a new **SQL Query Tab** by clicking the "SQL+" icon in the toolbar.

#### Task 2: Understanding Basic Syntax

Before writing specific functions, you must understand the structural components of a function declaration 1\.  
**Basic Syntax Template:**  
CREATE FUNCTION function\_name(input\_variable\_name data\_type)   
RETURNS output\_data\_type  
BEGIN  
    \-- Code that does something with the input and gives output  
    RETURN output\_value;  
END;  
**Figure 1: Basic syntax diagram showing Input parameters and Output return types** 1

#### Task 3: Implementing Your First Function (Addition)

Start by creating a simple function that adds two integers 1\.  
**Critical Step: Handling Delimiters**In MySQL Workbench, you must change the statement delimiter from ; to $$ 1\. This prevents the Workbench from trying to execute the function line-by-line when it encounters a semicolon inside the BEGIN...END block 1\.  
**SQL Code Implementation:**

1. Type the following code into your Query Tab:

```sql
USE dd;
DELIMITER $$

CREATE FUNCTION add_numbers(x INT, y INT)  
RETURNS INT  
DETERMINISTIC  
BEGIN  
    RETURN x + y;  
END$$

DELIMITER ;
```

1. Highlight the entire block and click the **Lightning Bolt (Execute)** icon.

**Step 2: Use and Verify the Function**To test your function, run a standard SELECT statement 1\. The result will appear in the **Result Grid**:  

```sql
SELECT add_numbers(10, 5) AS result;  
```
**Figure 2: Screenshot of MySQL Workbench showing the code for add\_numbers and the Result Grid showing '15'** 1

#### Task 4: Function Declaration Characteristics

When creating functions in Workbench, you must specify how the function interacts with data using the following options 1:

* **DETERMINISTIC:** Indicates the function always produces the same result for the same input 1\.  
* **NOT DETERMINISTIC:** Indicates the results may vary (e.g., depends on the current date) 1\.  
* **NO SQL:** Indicates the function does not read or write any SQL data 1\.  
* **READS SQL DATA:** Indicates the function reads data from tables but does not modify them 1\.  
* **MODIFIES SQL DATA:** Indicates the function changes data in the database 1\.

#### Task 5: Practical Exercises

**Example 2: Converting Temperature (Celsius to Fahrenheit)**Create a function using the formula $F \= (C \\times 9/5) \+ 32$, where $C$ is DECIMAL(5,2) 1\.  

```sql
DELIMITER $$  
CREATE FUNCTION convert_temp(Cel decimal(5,2))  
RETURNS decimal(5,2)  
DETERMINISTIC  
BEGIN  
    RETURN (Cel * 9/5) + 32;  
END$$

DELIMITER ;
```

\-- Test the function in Workbench  

```sql
SELECT convert_temp(2.3);  
```

**Example 3: Calculate the Square of a Number**  

```sql
DELIMITER $$  
CREATE FUNCTION calculate_square(num INT)   
RETURNS INT  
DETERMINISTIC  
BEGIN  
    RETURN num * num;  
END$$  
DELIMITER ;
```

\-- Test the function  

```sql
SELECT calculate_square(3);  
```

**Example 4: Calculate the Cube of a Number**  

```sql
DELIMITER $$  
CREATE FUNCTION calculate_cube(num INT)   
RETURNS INT  
DETERMINISTIC  
BEGIN  
    RETURN num * num * num;  
END$$  
DELIMITER ;
```

\-- Test the function  

```sql
SELECT calculate_cube(3);  
```

**Example 5: Calculate the Perimeter of a Rectangle***Hint: The perimeter of a rectangle is $2 \\times (length \+ width)$* 1\.  

```sql
DELIMITER $$  
CREATE FUNCTION rectangle_perimeter(length DECIMAL(5, 2), width DECIMAL(5, 2))   
RETURNS DECIMAL(5, 2\)  
DETERMINISTIC  
BEGIN  
    RETURN 2 * (length + width);  
END$$  
DELIMITER ;
```

\-- Test the function  

```sql
SELECT rectangle_perimeter(5, 3);
```

#### Task 6: Conditional Logic within Functions

**Example 6: Determine if a Number is Even or Odd**Use a conditional statement (IF) to check the result of the modulo operation 1\. A number is even if it is divisible by 2 (i.e., num % 2 \= 0\) 1\.  

```sql
DELIMITER $$  
CREATE FUNCTION is_even(num INT)   
RETURNS VARCHAR(5)  
DETERMINISTIC  
BEGIN  
    RETURN IF(num % 2 \= 0, 'Even', 'Odd');  
END$$  
DELIMITER ;
```

\-- Test the function  

```sql
SELECT is_even(4);
```

### 5\. Managing Functions in Workbench

* **Viewing Functions:** In the **Navigator** pane under your schema, expand the **Functions** folder to see your created functions.  
* **Refreshing:** If you do not see your function immediately, right-click the "Functions" folder and select **Refresh All**.  
* **Dropping a Function:** If you need to rewrite a function, you may need to use DROP FUNCTION function\_name; before recreating it.

### 6\. Summary

In this lab, you successfully implemented several custom functions using **MySQL Workbench** 1\. You learned how to manage delimiters to handle multi-line blocks, how to define return types, and how to apply mathematical and conditional logic within the database layer 1\. These skills allow you to write functions for a wide variety of examples in data science applications 1\.  
