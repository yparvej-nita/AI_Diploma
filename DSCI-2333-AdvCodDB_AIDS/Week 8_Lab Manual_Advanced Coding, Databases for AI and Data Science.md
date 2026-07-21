# **LAB MANUAL: Advanced Coding, Databases for AI and Data Science**
![Header Graphic](lab_manual_header_graphic.png)

## **Lab 8: Learn how to work with a csv file inside MySQL**

### **Roadmap & Objectives**
![Objectives Icon](learning_objective_icon.png)
At the end of this lab session, you will be able to work with a **CSV file** and solve some challenging problems.

---

### **Getting Started**
**Dataset Download:** Download the **Olympic Data Set** from the provided link in your course materials.
[Dataset](dataset/outturnOlympicGames.csv)

#### **Step 1: Create or Select a Database**
Open **MySQL Workbench**. You must either create a new database or select an existing one from the Navigator panel.

#### **Step 2: Use the Table Data Import Wizard**
1.  Right-click on your chosen database in the **Navigator** panel.
2.  Select **Table Data Import Wizard** from the context menu.
    ![Import Wizard Context Menu](mysql_workbench_import_wizard_context_menu.png)
3.  In the "Select File to Import" window, click **Browse...** to select the CSV file path.
    ![File Selection Wizard](mysql_import_wizard_file_selection.png)

---

### **Step 3: Initial Data Cleaning**
To ensure accurate analysis, you must replace blank values or placeholders (like `'**'`) with **NULL**.

**Important Syntax Note:** The column name `` `Cost, Billion USD` `` must be enclosed in **backticks** because it contains a comma and spaces.

```sql
-- To replace blank values with NULL
UPDATE games
SET `Cost, Billion USD` = NULL
WHERE `Cost, Billion USD` = ' ' OR `Cost, Billion USD` = '**';
```
![Update Code Block](sql_update_null_replacement.png)

---

### **Lab Exercises & Data Analysis**

#### **Problem 1: Hosting Frequency**
**Goal:** Identify which countries hosted the most Olympic Games.
*   `SELECT Country` to display names.
*   `GROUP BY country` to consolidate the data.
*   `COUNT(*)` to tally the hostings.
*   `ORDER BY num DESC` to arrange results from highest to lowest.

```sql
USE ddd; -- Replace with your schema name
SELECT Country, COUNT(*) as num
FROM Games
group by country
order by num DESC;
```
![Ordered Host Results](sql_query_count_host_descending.png)

> **Caution:** `COUNT(*)` can be used to count all rows in a table or group, **including those with NULL values**. However, you cannot use `*` with other aggregate functions like `SUM()`, `AVG()`, or `MIN()` because they require a **specific column** to perform calculations on.

#### **Problem 2: Seasonal Athlete Analysis**
What is the average number of athletes per Olympic Games, grouped by season (Winter/Summer)?

```sql
SELECT Type, AVG(Athletes) AS avg_athletes
FROM Games
GROUP BY Type;
```
![Seasonal Average Results](sql_query_avg_athletes_by_season.png)

#### **Problem 3: Unique Data Discovery**
Display the unique countries present in the dataset.

```sql
select distinct Country from games;
```
![Distinct Countries Result](sql_query_distinct_countries.png)

---

### **Section 4: Table Schema Modification**
The column name `` `Cost, Billion USD` `` is problematic for SQL syntax due to its spaces and comma. To avoid syntax errors, rename the column to **Cost** using the `ALTER` command.

```sql
-- Change column name and data type
ALTER TABLE Games
CHANGE COLUMN `Cost, Billion USD` Cost DECIMAL(10, 7);

-- Verify the change
SHOW COLUMNS FROM Games;
```
![Schema Modification Code](sql_alter_table_rename_column.png)

**Task:** Now calculate the total cost of hosting the games by country.

```sql
select country, sum(cost) as total_cost
from games
group by country;
```

---

### **Section 5: Advanced Analytics (Extremes & UNION)**
**Question:** What is the maximum and minimum number of athletes in any game?

To find the specific game with the maximum athletes, use a subquery:
```sql
SELECT Games, Athletes
FROM Games
WHERE Athletes = (SELECT MAX(Athletes) FROM Games);
```
![Subquery Max Athletes](sql_query_max_athletes_subquery.png)

To display **both** the maximum and minimum values in the **same output**, use a `UNION` query.

```sql
SELECT 'Max' AS Type, Games, Athletes
FROM Games
WHERE Athletes = (SELECT MAX(Athletes) FROM Games)
UNION
SELECT 'Min' AS Type, Games, Athletes
FROM Games
WHERE Athletes = (SELECT MIN(Athletes) FROM Games);
```
![Union Query Results](sql_query_union_max_min_athletes.png)

---
