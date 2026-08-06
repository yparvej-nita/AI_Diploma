# Lab 10: Performing ETL with AWS Glue

**Course:** Cloud Computing for Data Science

## 1\. Introduction

In modern data science, data is rarely in the perfect format for analysis when it is first collected. **Extract, Transform, and Load (ETL)** is the process used to bridge the gap between raw data and actionable insights. This lab explores **AWS Glue**, a fully managed, serverless ETL service that simplifies data preparation. You will learn how to automate data discovery, build a centralized metadata catalog, and transform raw CSV files into optimized Parquet formats to enable high-performance querying.

## 2\. Learning Objectives

By the end of this lab, you will be able to:

* Explain the three stages of the **ETL process**.  
* Provision cloud infrastructure using **AWS CloudFormation**.  
* Navigate and manage the **AWS Glue Data Catalog**.  
* Configure **AWS Glue Crawlers** to automatically discover data schemas.  
* Design and execute a serverless data transformation job using **AWS Glue Studio**.  
* Verify results by querying processed data with **Amazon Athena**.

## 3\. Prerequisites

* Access to the **AWS Management Console**.  
* Completion of **Lab 9** (Serverless Computing basics).  
* Basic understanding of **Amazon S3** bucket and folder management.  
* Provided data files: customers.csv and orders.csv.

## 4\. Background Theory

### 4.1 ETL: Extract, Transform, Load

* **Extract:** The process of pulling data from various sources such as Amazon S3 buckets, RDS databases, or external JDBC connections.  
* **Transform:** The stage where data is cleaned, enriched, and reformatted. This includes changing data types, adding timestamps, or converting files to columnar formats like Parquet.  
* **Load:** The final stage where the processed data is stored in a target destination, such as a Data Lake (S3) or a Data Warehouse (Redshift), for analysis.

### 4.2 AWS Glue Components

* **Data Catalog:** A centralized metadata repository that stores table definitions and schema information.  
* **Crawlers:** Automated programs that connect to data stores, determine the schema, and create metadata entries in the Data Catalog.  
* **Glue Studio:** A visual interface that allows you to design ETL workflows using a drag-and-drop graph without needing to write complex Apache Spark code.

### 4.3 Serverless Computing and Monitoring

AWS Glue follows the **serverless** paradigm, meaning there are no servers to manage, and it scales automatically to handle big data workloads. Like other serverless services (such as **AWS Lambda**), Glue utilizes **IAM Roles** to securely access resources and **Amazon CloudWatch** to log job execution details and monitor performance metrics.

## 5\. Infrastructure Setup Code

Use the following **AWS CloudFormation** template to provision your S3 bucket, IAM roles, and Athena workgroups.  
Description: This template deploys a bucket and creates a Glue IAM service role.  
Parameters:  
  S3BucketForCourse:  
    Description: Enter a unique name for your S3 bucket.  
    Type: String

Resources:  
  S3BucketForAWSGlueCourse:  
    Type: AWS::S3::Bucket  
    Properties:  
      BucketName: \!Ref S3BucketForCourse  
      Tags:  
        \- Key: "course"  
          Value: "AWSGlueDataScience"

  GlueIAMRole:  
    Type: AWS::IAM::Role  
    Properties:  
      RoleName: AWSGlueCourse  
      AssumeRolePolicyDocument:  
        Version: "2012-10-17"  
        Statement:  
          \- Effect: Allow  
            Principal:  
              Service: \[glue.amazonaws.com\]  
            Action: \[sts:AssumeRole\]  
      Policies:  
        \- PolicyName: AWSGlueCourseServicePolicy  
          PolicyDocument:  
            Version: "2012-10-17"  
            Statement:  
              \- Effect: Allow  
                Action:  
                  \- glue:\*  
                  \- lakeformation:\*  
                  \- s3:GetBucketLocation  
                  \- s3:ListBucket  
                  \- logs:PutLogEvents  
                Resource: "\*"

  MyAthenaWorkGroup:  
    Type: AWS::Athena::WorkGroup  
    Properties:  
      Name: AWSGlueCourseAthenaWorkgroup  
      State: ENABLED  
      WorkGroupConfiguration:  
        ResultConfiguration:  
          OutputLocation: \!Sub s3://${S3BucketForCourse}/athena

## 6\. Step-by-Step Lab Instructions

### Step 1: Provision Infrastructure

1. Log in to the AWS Console and search for **CloudFormation**.  
2. Click **Create stack** \-\> **With new resources (standard)**.  
3. Select **Upload a template file** and provide the [setup-code.yml](setup-code.yaml) file.
4. Name the stack myGlueStack and enter a unique **S3 Bucket name**.  
5. Click **Next** through the options, acknowledge the IAM capabilities, and click **Submit**.  
6. Wait for the status to show **CREATE\_COMPLETE**.

### Step 2: Organize Data in S3

* Navigate to the **S3** service and open your new bucket.  
* Click **Create folder** and create the following directories:  
* athena/  
* processedData/  
* rawData/  
* scriptLocation/  
* tmpDir/  
* Inside the rawData/ folder, create two more subfolders: customers/ and orders/.  
* Upload customers.csv to the customers/ folder and orders.csv to the orders/ folder.

### Step 3: Create the Glue Database

1. Navigate to the **AWS Glue** service.  
2. In the left sidebar under **Data Catalog**, select **Databases**.  
3. Click **Add database**.  
4. **Name:** raw\_data.  
5. **Location:** Enter the S3 URI for your rawData/ folder (e.g., s3://your-bucket-name/rawData/).

### Step 4: Manually Define the Customers Table

* Select **Tables** in the sidebar and click **Add table**.  
* **Name:** customers\_raw\_data.  
* **Database:** raw\_data.  
* **Data Store:** Select **S3** and browse to your customers/ folder.  
* **Format:** Select **CSV** with a comma delimiter.  
* **Schema:** Manually add the following columns:  
* customerid (int)  
* firstname (string)  
* lastname (string)  
* fullname (string)  
* Click **Next** and **Create**.

### Step 5: Automate Schema Discovery with a Crawler

1. Select **Crawlers** in the sidebar and click **Create crawler**.  
2. **Name:** mycrawlerfororderstable.  
3. **Data Source:** Add an S3 source pointing to your orders/ folder.  
4. **IAM Role:** Select the AWSGlueCourse role.  
5. **Target Database:** Select raw\_data.  
6. **Crawler Schedule:** Select **On demand**.  
7. Once created, select the crawler and click **Run crawler**. This will automatically detect the schema for the orders.csv file.

### Step 6: Create the Visual ETL Job

* Under **Data Integration and ETL**, select **Visual ETL**.  
* **Source:** Select **AWS Glue Data Catalog** and pick the customers\_raw\_data table.  
* **Transform:** Add an **Add Current Timestamp** node. Set the new column name to processed\_timestamp.  
* **Target:** Select **Amazon S3**.  
* **Format:** Parquet (Snappy compression).  
* **S3 Target Location:** Browse to your processedData/ folder.  
* **Data Catalog update:** Select **Create a table in the Data Catalog** and set the database to processed\_data (create this database if it doesn't exist).

### Step 7: Execute the Job

1. Go to the **Job details** tab.  
2. Assign the **IAM Role** AWSGlueCourse.  
3. Set the **Worker type** to G 1X and the **Number of workers** to 2\.  
4. Click **Save** and then **Run**.

## 7\. Expected Outputs

* **Data Catalog:** Three tables should appear—customers\_raw\_data, orders (via crawler), and customers\_processed (via job).  
* **S3 Storage:** The processedData/ folder will contain several .parquet files.  
* **Athena Queries:** Running a SELECT \* query on the processed table will show your original data alongside a new processed\_timestamp column.

## 8\. Troubleshooting and Best Practices

* **Role Permissions:** If a job or crawler fails with "Access Denied," ensure the IAM role has full read/write access to the specific S3 bucket.  
* **Partitioning:** For production workloads, always partition your data by date or region in S3 to improve query speed and reduce costs.  
* **Cost Management:** Always **Delete the CloudFormation stack** and **Empty the S3 bucket** when you are finished with the lab to stop AWS charges.

## 9\. Summary

This lab demonstrated a complete serverless ETL pipeline. By using AWS Glue, you moved from raw, unorganized CSV files to a structured Data Catalog and an optimized Parquet Data Lake. You learned that Crawlers save time on schema definition and Glue Studio provides a powerful visual way to transform data without deep coding knowledge.

## 10\. Review Questions

1. What are the three steps in the ETL process, and what happens in each?  
2. How does an AWS Glue Crawler simplify the work of a Data Engineer?  
3. What is the AWS Glue Data Catalog, and why is it considered a "metadata repository"?  
4. Why did we transform the CSV data into Parquet format instead of keeping it as CSV?  
5. Which AWS service would you use to run SQL queries against the tables defined in your Glue Data Catalog?  
6. Explain the benefit of using an IAM Role for an AWS Glue Job.  
7. What does "serverless" mean in the context of AWS Glue?

## 11\. Resources

Specify template  Info This GitHub repository (https://github.com/aws-cloudformation/aws-cloudformation-templates) contains sample CloudFormation templates that can help you get started on new infrastructure projects.