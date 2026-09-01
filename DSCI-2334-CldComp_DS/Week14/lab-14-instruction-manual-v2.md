# CSCI-430: Cloud Computing for Data Science
## LAB MANUAL: WEEK 14

# LAB 14: AWS Data Migration: From Amazon RDS to Amazon Redshift

**Academic Term:** Fall 2026  
**Document Classification:** Student & Instructor Lab Guide  
**Release Date:** September 1, 2026  

---

## Table of Contents
1. [Introduction](#1-introduction)
2. [Learning Objectives](#2-learning-objectives)
3. [Prerequisites](#3-prerequisites)
4. [Background Theory](#4-background-theory)
   - 4.1 [The Need for Data Migration](#41-the-need-for-data-migration)
   - 4.2 [Online Transaction Processing (OLTP) vs. Online Analytical Processing (OLAP)](#42-online-transaction-processing-oltp-vs-online-analytical-processing-olap)
   - 4.3 [AWS Service Roles: Amazon RDS & Amazon Redshift](#43-aws-service-roles-amazon-rds--amazon-redshift)
   - 4.4 [AWS Glue: Serverless Data Integration & Cataloging](#44-aws-glue-serverless-data-integration--cataloging)
   - 4.5 [VPC Gateway Endpoints: Secure S3 Routing](#45-vpc-gateway-endpoints-secure-s3-routing)
5. [Step-by-Step Lab Instructions](#5-step-by-step-lab-instructions)
   - [Session 1: Provisioning and Initializing the Transactional Database (Amazon RDS)](#session-1-provisioning-and-initializing-the-transactional-database-amazon-rds)
   - [Session 2: Provisioning and Configuring the Data Warehouse (Amazon Redshift)](#session-2-provisioning-and-configuring-the-data-warehouse-amazon-redshift)
   - [Session 3: Building the AWS Glue Infrastructure (Databases and Connections)](#session-3-building-the-aws-glue-infrastructure-databases-and-connections)
   - [Session 4: Bypassing S3 Connectivity Errors with VPC Gateway Endpoints](#session-4-bypassing-s3-connectivity-errors-with-vpc-gateway-endpoints)
   - [Session 5: Dynamic Schema Discovery with Glue Crawlers](#session-5-dynamic-schema-discovery-with-glue-crawlers)
   - [Session 6: Authoring and Executing the AWS Glue ETL Migration Job](#session-6-authoring-and-executing-the-aws-glue-etl-migration-job)
6. [Activities and Exercises](#6-activities-and-exercises)
7. [Expected Outputs / Results Verification](#7-expected-outputs--results-verification)
8. [Troubleshooting and Best Practices](#8-troubleshooting-and-best-practices)
9. [Summary](#9-summary)
10. [Review Questions](#10-review-questions)

---

## 1. Introduction
In modern corporate data architectures, organizations separation of operational transactional systems from analytical reporting warehouses is key to maintaining business continuity and application responsiveness. Running analytical queries on an operational database degrades application performance, impacting customer satisfaction. 

This lab guide introduces the mechanics of database migration using serverless cloud data integration services. You will establish an end-to-end data migration pipeline that extracts transactional data from **Amazon RDS (Relational Database Service)**, catalog schemas automatically using **AWS Glue Crawlers**, perform structural data mappings via **AWS Glue ETL**, and load the transformed records into an enterprise-grade cloud data warehouse, **Amazon Redshift**, for optimized analytical processing.

---

## 2. Learning Objectives
By the end of this lab session, you will be able to:
* **Articulate the architectural necessity** of migrating data from Online Transaction Processing (OLTP) stores to Online Analytical Processing (OLAP) warehouses.
* **Provision and initialize** an Amazon RDS MySQL instance and manage database schemas using DBeaver.
* **Deploy a single-node Amazon Redshift cluster** and configure database users, passwords, and security contexts.
* **Create AWS Glue Connections** to securely bridge relational JDBC data stores and column-oriented databases.
* **Deploy and run AWS Glue Crawlers** to automatically construct schemas in a centralized Data Catalog.
* **Architect a VPC S3 Gateway Endpoint** to bypass network routing hurdles and satisfy secure VPC connection constraints.
* **Write, configure, and execute a PySpark Glue ETL script** using the Spark engine to perform PII schema mapping and load tables into Redshift.

---

## 3. Prerequisites
To successfully complete this lab, you must have:
1. **AWS Console Credentials:** An active AWS Management Console session with permissions to create IAM roles, configure VPC Endpoints, provision RDS instances, launch Redshift clusters, and orchestrate AWS Glue jobs.
2. **SQL Client Access:** Local installation of DBeaver or an equivalent JDBC-compliant SQL client to manage tables on RDS MySQL.
3. **IAM Execution Role:** A secure IAM role (e.g., `rochak-glue-role` or an equivalent administrative profile) that possesses full access privileges to AWS Glue, Amazon Redshift, and Amazon RDS.

---

## 4. Background Theory

### 4.1 The Need for Data Migration
Operational databases are engineered for low-latency writes and fast individual lookups, processing transactions sequentially. When business intelligence analysts run heavy reporting queries—such as aggregation, grouping, or multi-table joins—across these operational systems, they consume extensive CPU and disk I/O resources. This resource exhaustion slows down customer-facing systems, leading to a degraded user experience. Data warehousing moves these historical analytics tasks out of the transactional sphere into an isolated warehouse containing consolidated, multi-source records optimized for bulk query performance.

### 4.2 Online Transaction Processing (OLTP) vs. Online Analytical Processing (OLAP)
Cloud databases are classified into two broad categories:
* **OLTP (Online Transaction Processing):** Optimized for frequent, high-concurrency read/write operations (e.g., shopping cart checkout, account creations). Data is stored row-by-row to guarantee write speed and integrity.
* **OLAP (Online Analytical Processing):** Optimized for complex read-heavy reporting queries spanning millions of rows (e.g., quarterly revenue trends, cohort analysis). Data is stored column-by-column to dramatically speed up aggregation computations.

### 4.3 AWS Service Roles: Amazon RDS & Amazon Redshift
* **Amazon RDS:** A fully managed relational database engine that automates hardware provisioning, database engine setup, security patching, and automated backups, allowing engineers to focus on coding and database design.
* **Amazon Redshift:** A cloud data warehouse service that implements Massively Parallel Processing (MPP) and column-oriented storage to enable fast querying of petabytes of structured data.

### 4.4 AWS Glue: Serverless Data Integration & Cataloging
AWS Glue is a serverless data integration service that automates extracting, transforming, and loading (ETL) tasks.
* **Glue Data Catalog:** A metadata store that houses database and table schemas representing your S3 directories or RDS/Redshift tables.
* **Glue Crawlers:** Automated scripts that connect to S3, RDS, or JDBC data sources, infer column data types and structures, and automatically register them as metadata tables in the Catalog.
* **Glue ETL Jobs:** Execution engines running Apache Spark under the hood to perform structural translations, mappings, filters, and loading sequences from source catalogs to target datastores.

### 4.5 VPC Gateway Endpoints: Secure S3 Routing
When an AWS Glue job processes data inside a private Virtual Private Cloud (VPC), it communicates with JDBC endpoints. However, Glue also requires access to Amazon S3 to read PySpark library assets and write temporary data buffers (especially for Redshift bulk uploads). If S3 communication travels over the public internet, it fails due to VPC routing constraints. A **VPC Gateway Endpoint** creates a direct, private route from the VPC to S3 without routing through public internet gateways, resolving S3 endpoint errors and ensuring high-throughput data transfers.

---

## 5. Step-by-Step Lab Instructions

### Session 1: Provisioning and Initializing the Transactional Database (Amazon RDS)

In this session, you will provision an operational MySQL database instance and seed it with customer records using DBeaver.

#### Step 1: Launch the MySQL Instance in Amazon RDS
1. In your AWS Management Console, search for and navigate to **RDS**.
2. Click **Create database**.
3. **Database creation method:** Select **Standard create**.
4. **Engine options:** Select **MySQL** as your database engine.
5. **Templates:** Select **Free tier** to prevent unneeded costs.
6. **Settings:**
   * **DB cluster identifier:** `rds-db` or similar.
   * **Master username:** Keep as `admin`.
   * **Master password:** Set a secure password and record it in a safe place.
7. **Connectivity:** Ensure **Public access** is set to **Yes** so your local SQL client can connect to the instance. (Note: In standard enterprise setups, this is typically kept private).
8. Leave all other parameters at their default values and click **Create database** at the bottom of the wizard.

![Figure 1: Amazon RDS database creation setup](./images/step1_rds_creation.png)  
*Figure 1: Choosing Standard Create with MySQL on the Free Tier template.*

#### Step 2: Retrieve the RDS Host Endpoint
1. Wait approximately 5–10 minutes for your database status to change to `Available`.
2. Click on the DB instance name (`rds-db`) to open its details page.
3. Locate the **Connectivity & security** tab.
4. Under **Endpoint & port**, copy the long alphanumeric host string (e.g., `rds-db.xxxxxxxx.us-east-1.rds.amazonaws.com`) and port number (`3306`).

![Figure 2: Finding RDS host endpoints](./images/step2_rds_endpoint.png)  
*Figure 2: Connectivity & security tab displaying host endpoint and port details.*

#### Step 3: Connect DBeaver and Seed Database Tables
1. Launch **DBeaver** on your local machine.
2. Select **Database** -> **New Database Connection** -> **MySQL**.
3. In the Host box, paste your RDS Host Endpoint. Set Port to `3306`.
4. Enter Database name as `dummy` (or connect to root first).
5. Under Username, enter `admin`, and fill in your master password. Click **Test Connection**. Once verified, click **Finish**.
6. Open an SQL Editor window in DBeaver and run the SQL script below to create a database, construct the table structure, and seed raw customer records:

```sql
-- Create operational database schema
CREATE DATABASE dummy;
USE dummy;

-- Create customer table structure
CREATE TABLE Persons (
    Id INT PRIMARY KEY,
    Name VARCHAR(255),
    Email VARCHAR(255)
);

-- Seed initial records into transactional store
INSERT INTO Persons (Id, Name, Email) VALUES 
(1, 'Ram', 'Brisbane Office'),
(2, 'Kim', 'Brisbane Office'),
(3, 'Shyam', 'Perth Office'),
(4, 'Barbie', 'Sydney Office');
```

7. Execute a simple `SELECT * FROM Persons;` to verify that your seed data has successfully written to Amazon RDS.

---

### Session 2: Provisioning and Configuring the Data Warehouse (Amazon Redshift)

In this session, you will spin up a columnar data warehouse cluster and configure the target table schema to receive the migrated records.

#### Step 4: Provision an Amazon Redshift Cluster
1. Navigate to the **Amazon Redshift** dashboard in your AWS Console.
2. Select **Clusters** in the left sidebar and click **Create cluster**.
3. **Cluster configuration:** Enter a unique name, such as `rds-redshift-cluster`.
4. **Node type:** Select **dc2.large** (optimized for compute and storage balance).
5. **Number of nodes:** Select **1** node for academic validation.
6. **Database configurations:**
   * **Admin user name:** Set to `admin`.
   * **Admin password:** Set a secure database password.
7. **Associated IAM roles:** Keep default options or assign your administrative role. Click **Create cluster**.

![Figure 3: Redshift cluster deployment properties](./images/step3_redshift_creation.png)  
*Figure 3: Creating an Amazon Redshift cluster with node type dc2.large.*

#### Step 5: Establish Database Connections in Query Editor v2
1. Once the cluster status shows `Available` (typically taking 5 minutes), click on the cluster name to open its landing page.
2. Click the **Query data** button on the top right, and select **Query in query editor v2** from the dropdown menu.
3. On the left sidebar of the Query Editor, click on your cluster name (`rds-redshift-cluster`).
4. A **Connection** window will display. Select **Database user name and password**.
5. Set Database name to `dev`. Enter the username `admin` and the password you defined during Redshift cluster setup.
6. Click **Create connection**.

![Figure 4: Redshift connection configuration](./images/step4_redshift_connection.png)  
*Figure 4: Connecting to cluster databases using Redshift credentials.*

#### Step 6: Create the Target Schema Table in Redshift
1. In the Query Editor v2 editor tab, create a target table matching your RDS relational model. Run the SQL statement below:

```sql
-- Create Target Table in the analytics warehouse
CREATE TABLE persons (
    Id INT,
    Name VARCHAR(255),
    Email VARCHAR(255)
);
```

2. Confirm the table exists in the `dev.public` directory by inspecting the schema browser.

---

### Session 3: Building the AWS Glue Infrastructure (Databases and Connections)

With your database and data warehouse active, you will configure AWS Glue databases and secure JDBC connections.

#### Step 7: Create Glue Databases
1. Search for and navigate to the **AWS Glue** console.
2. In the left panel under **Data Catalog**, select **Databases** and click **Add database**.
3. For the database name, enter `rds-database` (this will hold metadata for your operational RDS MySQL tables). Click **Create database**.
4. Click **Add database** again.
5. For this second database, enter `redshift-database` (this will hold metadata representing your Redshift warehouse tables). Click **Create database**.

![Figure 5: AWS Glue databases listing](./images/step5_glue_databases.png)  
*Figure 5: Registering separate target databases in the Glue Data Catalog.*

#### Step 8: Build an AWS Glue Connection to Amazon Redshift
1. In the left sidebar of the AWS Glue console, select **Connections**.
2. Click **Create connection**.
3. **Choose data source:** Select **Amazon Redshift** and click **Next**.
4. **Configure connection:**
   * **Database instance:** Select your active `rds-redshift-cluster`.
   * **Database name:** Enter `dev`.
   * **Password:** Enter the cluster administrator password. Click **Next**.
5. **Set properties:** Name your connection `Redshift-connection` and click **Next**.
6. Review the summary page and click **Create connection**.

![Figure 6: Registering Redshift JDBC Connections in Glue](./images/step6_redshift_connection.png)  
*Figure 6: Configuring cluster nodes and database credentials for Glue access.*

#### Step 9: Build an AWS Glue Connection to Amazon RDS MySQL
1. Go back to the **Connections** panel and click **Create connection**.
2. **Choose data source:** Select **MySQL** and click **Next**.
3. **Configure connection:**
   * **Database instance:** Select your RDS database instance (`rds-db`).
   * **Database name:** Enter your seeded relational schema `dummy`.
   * **Username / Password:** Set to `admin` and provide your master database password. Click **Next**.
4. **Set properties:** Name this connection `rds-connection` and click **Next**.
5. Click **Create connection** on the summary view.

---

### Session 4: Bypassing S3 Connectivity Errors with VPC Gateway Endpoints

Before launching Glue Crawlers to scrape JDBC schemas, you must configure a private gateway routing pathway to bypass S3 connection obstacles.

#### Step 10: Deploy a VPC Gateway Endpoint for Amazon S3
1. Navigate to the **VPC Console** in your AWS dashboard.
2. In the left panel, select **Endpoints**.
3. Click **Create endpoint** on the top right of the dashboard.
4. **Create endpoint details:**
   * **Name tag:** Enter `s3-gateway-endpoint` or similar.
   * **Service category:** Select **AWS services**.
   * **Services:** In the search filter, type `s3`. Select the service of type **Gateway** (e.g., `com.amazonaws.us-east-1.s3`).

![Figure 7: Gateway service selection in VPC console](./images/step7_vpc_endpoint_selection.png)  
*Figure 7: Choosing the S3 Gateway service for secure direct VPC routing.*

5. **VPC:** Select your cluster's **Default VPC**.
6. **Route tables:** Check the boxes next to all active route tables (specifically public and private subnets containing your RDS/Redshift clusters) to automatically propagate private gateway route paths.
7. Click **Create endpoint** at the bottom of the page.

---

### Session 5: Dynamic Schema Discovery with Glue Crawlers

In this session, you will configure crawlers to dynamically parse schemas from RDS and Redshift database connections, populating your Data Catalog tables.

#### Step 11: Create and Run the Redshift Schema Crawler
1. Open the **AWS Glue Console** and select **Crawlers** in the left sidebar.
2. Click **Create crawler**.
3. **Set crawler properties:** Name your crawler `redshift-crawl` and click **Next**.
4. **Choose data sources and classifiers:** Under Data sources, click **Add a data source**.
5. **Add data source details:**
   * **Data source:** Select **JDBC**.
   * **Connection:** Select `Redshift-connection` (created in Step 8).
   * **Include path:** Enter `dev/public/%` (this instructs the crawler to crawl all tables in the `public` schema within database `dev`).
   * Click **Add a JDBC data source**. Click **Next**.
6. **Configure security settings:** Under IAM role, select your administrative execution role (e.g., `rochak-glue-role`). This role must possess full permissions to interact with Glue, Redshift, and RDS resources. Click **Next**.
7. **Set output and scheduling:**
   * **Target database:** Select your `redshift-database` (created in Step 7).
   * **Frequency:** Set to **On demand**.
8. Click **Create crawler** on the review page.

#### Step 12: Create the RDS Schema Crawler
1. Go back to the **Crawlers** list and click **Create crawler**.
2. **Set crawler properties:** Name your crawler `rds-crawl` and click **Next**.
3. **Choose data sources:** Click **Add a data source**.
   * **Data source:** Select **JDBC**.
   * **Connection:** Select `rds-connection` (created in Step 9).
   * **Include path:** Enter `dummy/%` to target tables inside database `dummy`.
   * Click **Add a JDBC data source** and click **Next**.
4. **Configure security:** Select your administrative execution role (`rochak-glue-role`).
5. **Set output and scheduling:**
   * **Target database:** Select `rds-database`.
   * **Frequency:** Select **On demand**.
6. Click **Create crawler**.

#### Step 13: Execute Crawlers to Populate the Data Catalog
1. Select the checkboxes next to both `redshift-crawl` and `rds-crawl` in the Crawlers list.
2. Click **Run crawler**.
3. Monitor status. The status will transition from *Running* to *Stopping* and finally back to *Ready*. This takes about 2 minutes.
4. Go to **Tables** on the left panel. You will see two new catalog tables successfully created:
   * `dev_public_persons` (representing the Target Redshift table).
   * `dummy_persons` (representing the Source RDS MySQL table).

![Figure 8: Populated Data Catalog tables](./images/step8_catalog_tables.png)  
*Figure 8: Tables view showing inferred metadata and database mappings.*

---

### Session 6: Authoring and Executing the AWS Glue ETL Migration Job

Now that your schemas are cataloged, you will write a PySpark ETL script to extract operational records, map fields, and load them into your analytical warehouse.

#### Step 14: Construct and Launch the Glue ETL Job
1. In the AWS Glue Console, select **ETL jobs** under Data Integration and ETL on the left panel.
2. Under Create job, select **Script editor**.
3. Choose the default Spark runtime settings and click **Create**.
4. In the code editor tab, replace all existing code with the customized Spark migration script provided below.

```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Resolve the required job parameter array
args = getResolvedOptions(sys.argv, ["JOB_NAME"])

# Initialize PySpark Contexts
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Initialize AWS Glue Job lifecycle
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# 1. EXTRACT: Extract records from operational database using Catalog metadata
AWSGlueCatalog_node1705396692309 = glueContext.create_dynamic_frame.from_catalog(
    database="rds-database",
    table_name="dummy_persons",
    transformation_ctx="AWSGlueCatalog_node1705396692309",
)

# 2. TRANSFORM: Perform Schema Mappings (Source Schema -> Target Schema)
ChangeSchema_node1705396724035 = ApplyMapping.apply(
    frame=AWSGlueCatalog_node1705396692309,
    mappings=[
        ("email", "string", "email", "string"),
        ("id", "int", "id", "int"),
        ("name", "string", "name", "string"),
    ],
    transformation_ctx="ChangeSchema_node1705396724035",
)

# 3. LOAD: Bulk load mapped records into the Redshift target warehouse
AWSGlueCatalog_node1705396732800 = glueContext.write_dynamic_frame.from_catalog(
    frame=ChangeSchema_node1705396724035,
    database="redshift-database",
    table_name="dev_public_persons",
    redshift_tmp_dir=args["TempDir"],
    transformation_ctx="AWSGlueCatalog_node1705396732800",
)

# Commit job configurations
job.commit()
```

5. Click **Job details** at the top of the editor.
6. Name the job `rds-to-redshift-migration`.
7. Select your execution IAM role (e.g., `rochak-glue-role`).
8. Expand the **Advanced properties** section. Scroll down and enter a valid S3 directory in the **Temporary path** box (e.g., `s3://your-bucket-name/tmpDir/`). Redshift requires an S3 staging directory to manage high-speed bulk inserts.
9. Click **Save** and then click **Run** at the top right of the dashboard.

---

## 6. Activities and Exercises

### Activity 1: Query Execution & Row Validation in Redshift
Once the Glue Job execution status shows **Succeeded** (about 2–3 minutes), verify that the data has migrated successfully.
1. Navigate back to your **Amazon Redshift Query Editor v2** tab.
2. Open a new SQL query editor and execute the query below:

```sql
SELECT * FROM persons;
```

Your query results should display the 4 seeded customer records migrated directly from Amazon RDS. Record your results and insert a screenshot of the output in your lab report.

![Figure 9: Redshift migrated table query results](./images/step9_query_results.png)  
*Figure 9: SQL query editor displaying our four customer records successfully migrated from RDS MySQL.*

### Exercise 1: Expanding schemas and adding tracking columns
1. Open DBeaver and connect to your RDS MySQL database.
2. Modify your source `Persons` schema by running the SQL statement below:

```sql
ALTER TABLE Persons ADD COLUMN Country VARCHAR(100) DEFAULT 'Australia';
```

3. Update your records in RDS so that each person has a unique country string.
4. Create a new column in your Target Redshift table:

```sql
ALTER TABLE persons ADD COLUMN country VARCHAR(100);
```

5. **Task:** Rerun your Glue Crawlers to update your Catalog schemas. Next, open your `rds-to-redshift-migration` Glue job and modify the Python mappings array inside the `ApplyMapping.apply` transform to map the new `country` column from source to target. Run the job and execute a select query in Redshift to verify that your new column values migrated successfully.

### Exercise 2: PySpark Filtering and Email Masking
For data security, PII (Personally Identifiable Information) columns must often be sanitized before loading into a shared data warehouse.
1. Open your Glue Job script editor.
2. Under the Extract node, write standard PySpark code to filter out any records that do not contain the term `@example.com` or perform string manipulation to replace the email records with a masked string (`"REDACTED"`).
3. Hint: Convert the AWS Glue DynamicFrame into a standard PySpark DataFrame using `.toDF()`, apply your filter or map function, and convert it back to a DynamicFrame using `DynamicFrame.fromDF()` before calling `ApplyMapping`.

---

## 7. Expected Outputs / Results Verification
To earn credit for this lab, you must provide proof of the following completed resources:
1. **S3 Endpoint:** A gateway endpoint named `s3-gateway-endpoint` configured inside your target VPC.
2. **Glue Connections:** Two active, validated connections named `rds-connection` and `Redshift-connection`.
3. **Glue Data Catalog:** Two parsed schema tables (`dummy_persons` and `dev_public_persons`) inside your Glue registry databases.
4. **AWS Glue Job Run:** A successful job execution log for `rds-to-redshift-migration` showing 0 errors.
5. **Redshift Target Table Query:** A query output screenshot from Query Editor v2 demonstrating four successfully migrated rows in table `persons`.

---

## 8. Troubleshooting and Best Practices

### Troubleshooting Common Lab Pitfalls
* **Glue Connection Timeout Errors:** If your Glue Crawlers or Jobs hang on "Running" for over 10 minutes and then fail with a timeout, check your RDS and Redshift security groups. You must create an **Inbound Rule** inside your Security Group that permits the AWS Glue service to access database JDBC ports.
* **Glue IAM Access Denied Exceptions:** Ensure the IAM role assigned to your crawlers and jobs has policy permissions attached for VPC interface creations (`ec2:CreateNetworkInterface`, `ec2:DeleteNetworkInterface`), AWS Glue service execution policies, Amazon S3 bucket read/write privileges, and Redshift cluster access permissions.
* **Missing TempDir Parameters:** If your Glue Job fails with "TempDir must be defined," ensure you populated the **Temporary path** box under Advanced properties in your Glue Job details. AWS Redshift loads data by first exporting Spark records into a temporary S3 folder as CSV/Parquet and executing a high-speed SQL `COPY` command to import those S3 chunks into Redshift database nodes.
* **Database Name Sensitivity:** Keep in mind that RDS MySQL database/table names are case-sensitive on some operating systems. Glue crawls database names in lowercase by default, which can cause target mismatch errors in your PySpark catalog path if you use capitalized identifiers.

### Production Best Practices
* **S3 Gateway routing is required:** Always run database crawlers and ETL scripts within private VPC subnets and route AWS traffic privately via S3 Gateway endpoints to secure big data transfers.
* **Utilize Redshift Spectrum for flat files:** For massive unstructured analytical workloads, query flat files directly on S3 using Amazon Redshift Spectrum without running full migration pipelines.
* **Decouple compute and storage:** Delete or pause your Redshift cluster when not in use to avoid ongoing EC2 instance charges.

---

## 9. Summary
This laboratory demonstrated how to build a managed database migration pipeline. You established transactional architectures on RDS and analytics warehouses on Amazon Redshift, cataloged structural metadata using Glue Crawlers, bypassed S3 connectivity constraints within VPC networks using Gateway Endpoints, and successfully deployed PySpark ETL pipelines to extract, transform, and load operational records across services.

---

## 10. Review Questions

### Review Questions (with Answers)

#### Q1: Why is it bad practice to run analytical reporting queries directly on operational relational databases?
* **Answer:** Operational databases are optimized for rapid transactional writes and sequential updates. Large analytical aggregation queries consume massive amounts of CPU and memory, causing slow database performance and slowing down user-facing applications.

#### Q2: What is the operational difference between row-oriented databases (RDS MySQL) and column-oriented systems (Amazon Redshift)?
* **Answer:** RDS MySQL stores complete records row-by-row, which is optimal for transactional operations. Column-oriented databases like Amazon Redshift store data column-by-column, allowing analytical query engines to scan and compile specific parameters across millions of records with minimal disk read operations.

#### Q3: What function does an S3 Gateway Endpoint perform inside our private VPC network?
* **Answer:** It establishes a private, high-speed routing pathway directly between services inside your private subnets and Amazon S3 without routing traffic through the public internet, preventing "S3 connectivity errors" during Crawler runs.

#### Q4: What is the role of AWS Glue Crawlers in data management pipelines?
* **Answer:** Crawlers automatically connect to datastores (S3, RDS, Redshift) via JDBC, inspect the tables and schemas, determine column classifications and types, and register those metadata structures inside the Glue Data Catalog.

#### Q5: Why does AWS Glue require an S3 temporary folder to write data into Amazon Redshift?
* **Answer:** Redshift is optimized for bulk database writes. Rather than writing records row-by-row, the Glue Spark engine writes data in parallel into a temporary S3 staging directory and then executes a fast SQL `COPY` command to load those S3 chunks into Redshift nodes.

#### Q6: Explain what metadata represent in relation to the AWS Glue Data Catalog.
* **Answer:** Metadata represents "data about data." The Data Catalog does not contain actual customer records; instead, it stores schema structural details, column names, partitions, types, and connection locations, providing a query blueprint for ETL engines.

#### Q7: True or False: AWS Glue ETL Spark instances require manual server scaling.
* **Answer:** False. AWS Glue is serverless. Under the hood, AWS automatically provisions and destroys Spark cluster workers, dynamically scaling resources up or down based on your workload demands.

#### Q8: What does the `%` symbol mean in our crawler inclusion path `dev/public/%`?
* **Answer:** The `%` character serves as a wildcard operator, instructing the AWS Glue crawler to parse and register all schema tables discovered within the public schema of the target database.
