# CSCI-430: Cloud Computing for Data Science
## LAB MANUAL: WEEK 11

# LAB 11: Data Preparation for Analytics using AWS Glue DataBrew

**Academic Term:** Fall 2026 
**Document Classification:** Student & Instructor Lab Guide 
**Release Date:** August 23, 2026 

---

## Table of Contents
1. [Introduction](#1-introduction)
2. [Learning Objectives](#2-learning-objectives)
3. [Prerequisites](#3-prerequisites)
4. [Background Theory](#4-background-theory)
 - 4.1 [The Challenges of Data Wrangling](#41-the-challenges-of-data-wrangling)
 - 4.2 [What is AWS Glue DataBrew?](#42-what-is-aws-glue-databrew)
 - 4.3 [Core Architectural Components of DataBrew](#43-core-architectural-components-of-databrew)
 - 4.4 [Dynamic Data Partitioning in S3](#44-dynamic-data-partitioning-in-s3)
 - 4.5 [IAM and Service Permissions](#45-iam-and-service-permissions)
 - 4.6 [Pricing and DPU Consumption](#46-pricing-and-dpu-consumption)
5. [Session 1: Data Connection, Schema Discovery, and Automated Profiling](#5-session-1-data-connection-schema-discovery-and-automated-profiling)
 - 5.1 [Step 1: Initiate the Project and Connect S3 Dataset](#51-step-1-initiate-the-project-and-connect-s3-dataset)
 - 5.2 [Step 2: Interactive Data Exploration (Grid and Schema Views)](#52-step-2-interactive-data-exploration-grid-and-schema-views)
 - 5.3 [Step 3: Configuring and Executing a Data Profile Job](#53-step-3-configuring-and-executing-a-data-profile-job)
 - 5.4 [Step 4: Interpreting the Data Profile Report](#54-step-4-interpreting-the-data-profile-report)
6. [Session 2: Designing a Data Cleansing Recipe and Executing ETL Pipeline Jobs](#6-session-2-designing-a-data-cleansing-recipe-and-executing-etl-pipeline-jobs)
 - 6.1 [Step 5: Developing the Data Cleansing Recipe](#61-step-5-developing-the-data-cleansing-recipe)
 - 6.2 [Step 6: Publishing the Transformation Recipe](#62-step-6-publishing-the-transformation-recipe)
 - 6.3 [Step 7: Creating and Running the Scalable Recipe Job](#63-step-7-creating-and-running-the-scalable-recipe-job)
 - 6.4 [Step 8: Verifying Partitioned Outputs and Reviewing Data Lineage](#64-step-8-verifying-partitioned-outputs-and-reviewing-data-lineage)
7. [Activities and Exercises](#7-activities-and-exercises)
8. [Expected Outputs / Results Verification](#8-expected-outputs--results-verification)
9. [Troubleshooting and Best Practices](#9-troubleshooting-and-best-practices)
10. [Summary](#10-summary)
11. [Review Questions](#11-review-questions)

---


## 1. Introduction
In modern data science and business intelligence, raw data is rarely analysis-ready. Data scientists and engineers routinely spend up to 80% of their project lifecycle on "data wrangling"—the repetitive, tedious process of cleaning, normalizing, and formatting datasets. Anomalies like missing fields, non-standard date representation, and unranked categorical variables can skew statistical analysis and corrupt down-stream machine learning algorithms.

This lab introduces **AWS Glue DataBrew**, an advanced serverless visual data preparation tool that enables data analysts and scientists to cleanse and enrich massive datasets without writing complex Apache Spark code. By utilizing over 250 built-in transformations and automated statistical profiling, you will transition a complex COVID-19 daily tracking dataset from a raw, unorganized state into a highly structured, partitioned, and optimized format ready for high-performance SQL query engines.

---

## 2. Learning Objectives
By the end of this lab, you will be able to:
* **Establish Connections** to cloud-based S3 data stores and define datasets in AWS Glue DataBrew.
* **Conduct Automated Data Profiling** to discover statistical distributions, correlations, missing values, and overall data quality of a raw dataset.
* **Analyze Schemas** to modify column metadata, rename attributes, and enforce structural consistency.
* **Develop a Cleansing Recipe** composed of modular transformations such as data type conversion, column duplication, high-accuracy splitting, categorical value mapping, and null value imputation.
* **Publish Versioned Recipes** to foster collaborative development and enable automated deployment in production pipelines.
* **Deploy Scalable Spark-Based ETL Jobs** that automatically partition raw data by date (year, month, day) in S3 to maximize query efficiency and reduce S3 data scanning costs.
* **Interpret Data Lineage** to track the origin of the data and verify each step of the transformation pipeline.

---

## 3. Prerequisites
To successfully complete this lab, you must have:
1. **AWS Console Access:** An active AWS Management Console session with permissions to use S3, IAM, CloudWatch, and AWS Glue DataBrew.
2. **Prior Cloud Lab Foundation:** Successful completion of S3 and IAM fundamentals (similar to the S3 bucket creation and permissions concepts of Lab 8 and 9).
3. **Dataset Availability:** Access to the COVID-19 Daily States Tracking CSV file (`states_daily.csv`) provided within your class resources.
4. **Environment Deployment:** Your AWS lab environment must be pre-configured with a CloudFormation stack (typically named `databrew-lab` or similar) that outputs:
 - An S3 output bucket: `databrew-lab-databrewoutputs3bucket-xxxxx`.
 - A pre-configured IAM Service Role: `databrew-lab-DataBrewLabRole-xxxxx`.

---


## 4. Background Theory

### 4.1 The Challenges of Data Wrangling
Data wrangling involves identifying errors, correcting structural discrepancies, and transforming raw structures into clean, business-ready models. Common issues include:
* **Inaccurate Data Types:** Dates stored as integers (e.g., `20210213`) prevent chronological analysis and must be converted to standard string or ISO-8601 timestamps.
* **Dense Fields:** Combined variables must be split into multiple fields (such as extracting year, month, and day from a single date value) to enable multi-dimensional analytics.
* **Missing or Null Values:** Empty records (nulls) skew averages and trigger computation crashes. Replacing them with neutral values (imputation, e.g., setting missing probable cases to `0`) standardizes the dataset without introducing bias.
* **Unstructured Categories:** Text-based grades (e.g., `A+`, `B`, `C`) cannot be numerically plotted or correlated. Categorical mapping converts these values into ordinal ranks (integers) to support mathematical models.

### 4.2 What is AWS Glue DataBrew?
AWS Glue DataBrew is a visual data preparation tool designed to bridge the gap between complex big-data engineering and zero-code data analysis. Traditionally, performing big data transformations required writing PySpark or Scala scripts and manually tuning Spark clusters. DataBrew eliminates this overhead by presenting a web-based, spreadsheet-like interface. Behind the scenes, DataBrew automatically compiles your visual operations into highly scalable Apache Spark jobs, managing the underlying infrastructure dynamically.

### 4.3 Core Architectural Components of DataBrew
DataBrew operates on four main entities:
* **Datasets:** Metadata connections to S3, Amazon Redshift, Amazon RDS, or Glue Catalog tables. The dataset defines the format, schema, and location of the source files.
* **Projects:** The interactive workspace where you configure your transformations. A project loads a representative "sample" (typically 500 or 1,000 rows) of your dataset, allowing you to instantly preview the impact of your operations on a live web grid.
* **Recipes:** A sequence of clean-up steps defined in your project. Recipes are versioned, published, and applied to the full dataset during job execution.
* **Jobs:** Execution pipelines that run on the full dataset.
 - *Profile Jobs:* Scan the entire raw dataset to compile an extensive Data Quality report detailing statistical summaries, outlier detections, and value correlations.
 - *Recipe Jobs:* Apply a versioned Recipe to the entire dataset, scaling across multiple Spark workers and generating cleansed output files at the target location.

```
 +-----------------------+ +-------------------------+ +-----------------------+
 | S3 Raw Data Source | ---> | DataBrew Dataset (S3) | ---> | DataBrew Project |
 +-----------------------+ +-------------------------+ +-----------------------+
 |
 +----------------------------------------+
 | (Recipe Designer Interface on Sample Grid)
 v
 +-----------------------+ +-------------------------+ +-----------------------+
 | S3 Partitioned Data | <--- | DataBrew Recipe Job | <--- | Published Recipe v1.0|
 +-----------------------+ +-------------------------+ +-----------------------+
```

### 4.4 Dynamic Data Partitioning in S3
Data Partitioning is an advanced database design technique that groups files into logical sub-directories within S3 based on key column values. For example, partitioning by year, month, and day creates an S3 structure such as:
`s3://my-bucket/job-outputs/year=2021/month=02/day=13/`.

When query engines like Amazon Athena search this dataset, they leverage "partition pruning." Instead of executing a full-table scan over gigabytes of files, the engine navigates directly to the specific sub-folders matching the query's `WHERE` clause. This results in:
1. **Dramatic reduction in query execution times.**
2. **Substantial reduction in cost** (since AWS Athena charges based on the volume of data scanned).

### 4.5 IAM and Service Permissions
Because AWS services are isolated by default, AWS Glue DataBrew requires explicit administrative permission to interact with other resources. During this lab, you will assign DataBrew an **IAM Service Role**. This role contains policies allowing DataBrew to:
* Read input files from your target S3 buckets.
* Write output files and partition folders to S3.
* Create and run Spark clusters.
* Stream detailed execution logs to Amazon CloudWatch Logs for debugging.

### 4.6 Pricing and DPU Consumption
AWS Glue DataBrew is serverless and operates under a **pay-as-you-go** model, charging based on execution time and resources used.
* **Free Tier:** Students and developers receive **40 hours of free interactive session time** per month.
* **Jobs Charging:** Jobs are priced per node-hour using **Data Processing Units (DPUs)**. One DPU provides a pre-configured capacity of CPU and memory.
* **Serverless Cost Efficiency:** Because infrastructure is dynamically provisioned and deleted immediately upon job completion, you never pay for idle hardware.

---


## 5. Session 1: Data Connection, Schema Discovery, and Automated Profiling

In this first session, you will establish connection to the target dataset, explore its basic layout, configure an IAM role, and execute an automated profiling job to generate a full Data Quality analysis report.

### 5.1 Step 1: Initiate the Project and Connect S3 Dataset
1. Log in to the **AWS Management Console** and search for **AWS Glue DataBrew** in the top services search bar. Select it to open the console.
2. Click the orange **Create project** button on the landing page.
3. In the **Project details** panel, enter a descriptive project name:
 * **Project name:** `covid-data-analysis`
4. In the **Recipe details** panel, verify that **Create new recipe** is selected. The console will automatically populate a recipe name, such as `covid-data-analysis-recipe`.
5. In the **Select a dataset** panel, click the radio button for **New dataset**.
6. Under **New dataset details**, enter the dataset name:
 * **Dataset name:** `states-daily`![Figure 1: Initializing the DataBrew Project and Dataset](./images/step1_project_details.png) 
*Figure 1: Setting up Project details, Dataset name, and selecting a new recipe.*

7. Under **Connect to new dataset**, select the **File upload** or **Amazon S3** option.
8. Click **Choose file** and upload the local `states_daily.csv` file from your workstation.
9. Under **Enter S3 destination**, browse to select your pre-configured S3 bucket (e.g., `s3://nikhil-bucket-for-databrew/` or your assigned student bucket name). This is the staging directory where the CSV file will be stored.
10. Under **Additional configurations**, verify the following parameters are selected:
 * **File type:** `CSV`
 * **CSV delimiter:** `Comma (,)`
 * **Column header values:** Select `Treat first row as header`![Figure 2: Configuring S3 Data Destination and CSV Parsing](./images/step1_dataset_upload.png) 
*Figure 2: Selecting files, entering S3 bucket destination, and configuring column headers.*

11. Under **Sampling** (optional section), keep the default setting:
 * **Type:** `First n rows`
 * **Rows to sample:** `500`![Figure 3: Configuring Sampling Threshold](./images/step1_sampling.png) 
*Figure 3: Maintaining the default 500-row sample for local interactive previewing.*

12. Under **Permissions**, select **Create new IAM role** from the Role name dropdown menu.
13. In the **New IAM role suffix** text box, enter a suffix (e.g., `my-data-brew-role`).
14. Click the orange **Create project** button.![Figure 4: Defining IAM Service Permissions and Initiating Project](./images/step1_permissions.png) 
*Figure 4: Creating a custom IAM role to allow DataBrew access to S3 resources.*

### 5.2 Step 2: Interactive Data Exploration (Grid and Schema Views)
1. Upon clicking Create Project, a screen stating **"Your session will be ready soon! Provisioning compute..."** will load. This takes approximately 1 minute as AWS provisions a serverless container to host your interactive preview session.![Figure 5: Provisioning Serverless Compute Environment](./images/step2_provisioning.png) 
*Figure 5: DataBrew automatically allocating background container instances.*

2. Once loaded, the project opens in the **Grid view**. Examine the interface. The main window displays:
 * The first 500 rows of your dataset.
 * The automatically inferred data type of each column (indicated by icons such as `#` for integer or `ABC` for string).
 * Summary of ranges of values discovered.
 * Interactive statistical distributions (histograms) located directly inside each column header for numeric variables.![Figure 6: Interactive Grid View Dashboard](./images/step2_grid_view.png) 
*Figure 6: Spreadsheet-like workspace displaying fields, data types, and distribution histograms.*

3. Locate and click on the **Schema** tab at the top right of the grid panel.
4. In the **Schema view**, review the structural overview. Here, you can easily:
 * Select a column's checkbox to view its statistics summary.
 * Toggle the visibility checkbox to show or hide fields.
 * Change data types, rename fields, or rearrange column order.![Figure 7: DataBrew Schema View Definition](./images/step2_schema_view.png) 
*Figure 7: Inspecting high-level schema structures, value validations, and missing value percentages.*

### 5.3 Step 3: Configuring and Executing a Data Profile Job
Interactive previewing is limited to the 500-row sample. To perform data profiling across the entire dataset, you must execute a Profile Job.

1. Locate and click the **Profile** tab (situated next to Grid and Schema tabs).
2. Click the orange **Run data profile** button.![Figure 8: Initiating Data Profiling Engine](./images/step3_run_profile.png) 
*Figure 8: Launching the automated data cataloging and diagnostic interface.*

3. In the **Job details** configuration window, enter the following properties:
 * **Job name:** `covid-states-daily-profile-job`
 * **Job run sample:** Select **Custom sample** and enter `20000` (this ensures the profiling scan covers up to 20,000 records, spanning the entire file).
4. Under **Job output settings**, specify where the profile analysis report should be stored:
 * **S3 bucket owner's account:** Select `Current AWS account`.
 * **S3 location:** Click Browse and select your dataset bucket. Append `/data-profile/` to the end of the S3 path (e.g., `s3://nikhil-bucket-for-databrew/data-profile/`). This is critical to keep S3 folders organized.![Figure 9: Setting up S3 Destinations and Job Parameters](./images/step3_profile_params.png) 
*Figure 9: Configuring job names, sample size, and output paths.*

5. In the **Permissions** panel, select the IAM role you generated in Step 1 (e.g., `AWSGlueDataBrewServiceRole-my-data-brew-role`).
6. Click the orange **Create and run job** button.![Figure 10: Applying Security Roles and Running the Job](./images/step3_run_profile_job.png) 
*Figure 10: Setting the service role and launching the automated profile job.*

7. In the left navigation menu, click the **Jobs** icon (the small play button icon) and navigate to the **Profile jobs** tab.
8. Monitor the execution status of `covid-states-daily-profile-job`. The status will transition from *Submitted* to *Running*.
9. **Note:** The data profile job takes approximately **5 minutes** to compile. Once completed, the status will show **Succeeded**.

### 5.4 Step 4: Interpreting the Data Profile Report
1. Once the profile job is complete, click the blue **View data profile** button under the Data Profile column in the list.![Figure 11: Locating the Completed Profile Job](./images/step4_jobs_list.png) 
*Figure 11: Viewing jobs status and opening completed profile dashboards.*

2. The **Data profile overview** tab launches, presenting a rich metadata dashboard:
 * **Summary metrics:** Displays Total Rows (e.g., `19,541`), Total Columns (`55`), Valid cells (`61%`), and Missing cells (`39%`).
 * **Correlations matrix:** A heat map demonstrating correlation coefficients (ranging from `-1.0` to `+1.0`) between numerical variables, showing how fields interact.![Figure 12: Automated Profile Summary Dashboard](./images/step4_profile_summary.png) 
*Figure 12: Summary of row/column count, validation rates, and the correlation matrix.*

3. Click on the **Column statistics** tab next to the overview.
4. Browse individual columns to check deep statistics. Review the metric breakdown for:
 * Outlier count, missing values percentage, and standard deviation.
 * Top distinct values and cardinality.
 * Value distribution graphs.![Figure 13: Granular Column-by-Column Statistics](./images/step4_column_stats.png) 
*Figure 13: Discovering that date is formatted as an integer, and probableCases has high null rates.*

---


## 6. Session 2: Designing a Data Cleansing Recipe and Executing ETL Pipeline Jobs

Having diagnosed the dataset's structural anomalies in Session 1, you will now design and apply an 8-step cleansing Recipe, publish it, and run a production-scale job to generate dynamically partitioned S3 files.

### 6.1 Step 5: Developing the Data Cleansing Recipe
To return to your project environment, click **Projects** on the left menu of the DataBrew console and select your `covid-data-analysis` project.

We will apply the following transformations to clean and prepare our dataset:
1. Convert the `date` column from an integer to a string.
2. Duplicate the `date` column (to preserve the original for reference while processing splits).
3. Split the duplicated date column into three distinct columns: `year`, `month`, and `day`.
4. Replace missing/null values in the `probableCases` column with `0`.
5. Map text-based categorical grades in `dataQualityGrade` to numeric ordinal values.
6. Enforce proper integer data types on the mapped field.

Let's implement each transformation step:

#### Step 5.1: Convert Date to String
The `date` column contains integer values (e.g., `20210213`). We must convert this to a string type before performing string-manipulation splits.
1. Hover over the column header for **date** in the Grid view.
2. Click the numeric `#` icon located on the top-left corner of the column header.
3. In the type selection dropdown, select **string**.
4. In the **Change data type** details panel on the right, click the orange **Apply** button.![Figure 14: Converting Date Column Type](./images/step5_date_type.png) 
*Figure 14: Converting inferred integer types to string formats.*

5. Verify that the transformation has been successfully registered on the right-side panel under the **Recipe** box.![Figure 15: Tracking Transformation Steps in the Project Recipe](./images/step5_recipe_step1.png) 
*Figure 15: The recipe panel automatically updates with step 1: "Change type of date to String."*

#### Step 5.2: Duplicate Date Column
Since the column splitting process automatically deletes the source column being split, we must first duplicate `date` to preserve a master date copy.
1. Click the **three dots (...)** icon at the top-right of the `date` column header.
2. From the pop-up dropdown menu, scroll down and click **Duplicate**.
3. In the **Duplicate column** dialog, accept the default name `date_copy` and click **Apply**.![Figure 16: Duplicating Columns to Protect Source Fields](./images/step5_duplicate.png) 
*Figure 16: Duplicating the date column. A new column named "date_copy" appears on the grid.*

#### Step 5.3: Extracting Year (First Split)
The date format is `YYYYMMDD` (length 8). We will split out the first 4 characters to extract the year.
1. Click the **three dots (...)** at the top-right of your new **date_copy** column header.
2. Select **Split column** -> **At positions from beginning**.
3. In the Split column options panel:
 * **Split column:** Select `Using positions`.
 * **Position from the beginning:** Enter `4`.
4. Click **Preview changes** to verify the split. The original `date_copy` will be deleted, and two new columns will be generated: `date_copy_1` (containing `YYYY`) and `date_copy_2` (containing `MMDD`).
5. Click **Apply**.![Figure 17: Splitting Column by Position Indexes](./images/step5_split_year.png) 
*Figure 17: Extracting the 4-digit year into a new column.*

#### Step 5.4: Extracting Month and Day (Second Split)
Now, we must split `date_copy_2` (which contains `MMDD`) to isolate month and day.
1. Click the **three dots (...)** on the **date_copy_2** column header.
2. Select **Split column** -> **At positions from beginning**.
3. In the Split column options panel, enter `2` under **Position from the beginning** (since Month occupies the first 2 characters of `MMDD`).
4. Click **Apply**. This generates `date_copy_2_1` (Month) and `date_copy_2_2` (Day).![Figure 18: Isolating Month and Day](./images/step5_split_month_day.png) 
*Figure 18: Splitting MMDD. Two columns are generated: month (first 2 digits) and day (remaining 2 digits).*

#### Step 5.5: Rename Split Columns
We must rename our generic split columns to proper names.
1. Click the **three dots (...)** on the **date_copy_1** column. Select **Rename**.
2. In the dialog, change the name to `year` and click **Apply**.![Figure 19: Renaming Column Headers](./images/step5_rename_year.png) 
*Figure 19: Renaming date_copy_1 to "year."*

3. Repeat the rename steps for the remaining split columns:
 * Rename `date_copy_2_1` to `month`.
 * Rename `date_copy_2_2` to `day`.![Figure 20: Cleansed Date Structure Schema](./images/step5_date_cleansed.png) 
*Figure 20: The visual grid displaying the original date and the newly created year, month, and day columns.*

#### Step 5.6: Fill Missing Values in Probable Cases
Our data profile report highlighted that `probableCases` contains blank/null rows. We will impute these with `0`.
1. Rather than scrolling through dozens of fields to find the column, click the **Columns** dropdown search bar at the top-left of the grid panel.
2. Search for `probableCases` and click **View** to instantly navigate to the column.![Figure 21: Utilizing Column Search Navigation Tools](./images/step5_column_search.png) 
*Figure 21: Quickly jumping to any column using the built-in metadata search box.*

3. Click the **three dots (...)** on the `probableCases` column header.
4. Select **Remove or fill missing values** -> **Fill with custom value**.
5. In the Missing values configurations panel, enter `0` as the **Custom value**.
6. Click **Apply**.![Figure 22: Imputing Missing Records](./images/step5_impute_nulls.png) 
*Figure 22: Configuring missing value properties to replace nulls with 0.*

#### Step 5.7: Categorically Map Data Quality Grade to Numerical Scale
The `dataQualityGrade` column contains text labels: `A+`, `A`, `B`, `C`, `D`, and `N/A`. We will map these into numerical values to make them readable for analytical processing.
1. Search and navigate to the **dataQualityGrade** column using the columns search dropdown at the top.
2. Click the **three dots (...)** on the `dataQualityGrade` column.
3. Select **Categorical mapping**.
4. In the mapping configurations panel, select the option **Map all values**.
5. Check the box for **Map values to numeric values**.
6. Complete the mapping table as follows to establish an ordinal scale:

| Original String Value | Mapped Numeric Integer Value |
|:--- |:--- |
| **N/A** | `0` |
| **A+** | `1` |
| **A** | `2` |
| **B** | `3` |
| **C** | `4` |
| **D** | `5` |![Figure 23: Defining Ordinal Categorical Mapping Rules](./images/step5_mapping_dialog.png) 
*Figure 23: Standardizing alphanumeric grades to numerical indexes based on the mapping table.*

7. Leave all other settings as default and click **Apply**. DataBrew creates a new mapped column named `dataQualityGrade_mapped`.

#### Step 5.8: Convert Mapped Grade to Integer
The newly created `dataQualityGrade_mapped` column is automatically set to a floating-point (double) type. Since our ranks are distinct integers, we must convert the data type.
1. Hover over the `dataQualityGrade_mapped` column header.
2. Click the decimal `#` type icon on the top-left of the column header.
3. Select **integer** from the dropdown menu.
4. Click **Apply** in the Change data type panel.

### 6.2 Step 6: Publishing the Transformation Recipe
You have built a comprehensive 10-step cleansing recipe. To execute this recipe inside a production pipeline job, you must publish it.

1. Locate the **Recipe** box on the right-hand panel of your screen and review the steps.
2. Click the **Publish** button located at the top-right of the Recipe box.
3. (Optional) Enter a version description, such as "Initial release of COVID daily data cleansing recipe".
4. Click the orange **Publish** button. The recipe is compiled and activated as **Version 1.0**.![Figure 24: Verifying the Completed Recipe and Publishing](./images/step6_publish_recipe.png) 
*Figure 24: Publishing recipe Version 1.0, making it available for production-level ETL jobs.*

### 6.3 Step 7: Creating and Running the Scalable Recipe Job
We will now execute a Spark-based Recipe Job on the full dataset, applying our transformations and outputting partitioned CSV files.

1. Click on **Jobs** from the left navigation menu of your DataBrew console.
2. On the **Recipe jobs** tab, click the orange **Create job** button.
3. In the Job details panel, enter the following parameters:
 * **Job name:** `covid-states-daily-prep`
 * **Job type:** Verify **Create a recipe job** is selected.
 * **Job input:** Under Run on, select **Dataset** and choose your original `states-daily` dataset.
 * **Select a recipe:** Ensure `covid-states-daily-recipe` is selected, and set **Recipe version** to `Version 1.0`.![Figure 25: Initializing Recipe Job Configurations](./images/step7_create_job.png) 
*Figure 25: Naming the job, linking input datasets, and selecting the published recipe version.*

4. Under **Job output settings**, specify S3 destinations and formatting properties:
 * **Output to:** `Amazon S3`.
 * **File type:** `CSV`.
 * **Delimiter:** `Comma (,)`.
 * **Compression:** `None`.
 * **S3 bucket owner's account:** `Current AWS account`.
 * **S3 location:** Browse S3, select your target bucket (e.g., `s3://databrew-lab-databrewoutputs3bucket-xxxxx/` or similar), and append `/job-outputs/` at the end.![Figure 26: Customizing ETL Formats and Output Destinations](./images/step7_output_settings.png) 
*Figure 26: Setting target bucket locations and configuring CSV delimiters.*

5. On the right side of the Job output box, click the **Settings** button (with the small gear icon).
6. In the **Output settings** configuration window, set up partitioning:
 * Under File output storage, select **Create a new folder for each job run**.
 * Under **File partitioning**, click **Enabled** to expand partitioning options.
 * Under Columns to partition by, click the text box, search, and add the split columns in this exact sequence:
 1. `year`
 2. `month`
 3. `day`
 * Click **Save**.![Figure 27: Configuring S3 Data Partitioning Keys](./images/step7_partitioning.png) 
*Figure 27: Setting up the partition folder hierarchy to segment output files by year, month, and day.*

7. Under **Permissions**, select the IAM role linked to your CloudFormation stack (which will look like `databrew-lab-DataBrewLabRole-xxxxx`).
8. Click **Create and run job**.![Figure 28: Activating Permissions and Launching Job Execution](./images/step7_run_job.png) 
*Figure 28: Applying execution permissions and submitting the recipe job.*

9. The job will initiate. Navigate to the **Jobs** page to monitor its progress. The run status will display **Running**.
10. The job executes across serverless Spark nodes and will complete in approximately **4 minutes**. Wait until the status changes to **Succeeded**.![Figure 29: Recipe Job Completed Successfully](./images/step7_job_success.png) 
*Figure 29: Success screen showing execution time, data capacity, and target output links.*

### 6.4 Step 8: Verifying Partitioned Outputs and Reviewing Data Lineage
To verify the results of your ETL pipeline:

1. Click on the S3 output path link shown in your successful job run details, or navigate directly to the **Amazon S3 Console** and open your output bucket.
2. Open the **job-outputs** directory. You will see that DataBrew has automatically structured your dataset into a clean partition hierarchy:
 * Click on the `year=2021/` folder.
 * Inside, open the `month=02/` folder.
 * Inside, open the `day=13/` folder.
 * Observe the processed, clean CSV file stored inside. DataBrew has split and grouped your massive raw file into individual, lightweight partitions!![Figure 30: S3 Partition Folders Overview](./images/step8_s3_partitions.png) 
*Figure 30: Folder nesting in Amazon S3 demonstrating successfully implemented partitioning.*

3. Navigate back to your AWS Glue DataBrew console and open your `covid-states-daily` project.
4. Click the **Lineage** button located at the top-right corner of your grid dashboard.
5. This launches the **Data Lineage** chart, visually demonstrating the end-to-end data pipeline:
 * You can see the origin of your raw data (`S3 states_daily.csv`).
 * The intermediate dataset mapping.
 * The project node detailing your recipe steps.
 * The output files generated by the published recipe.![Figure 31: Data Lineage Graph View](./images/step8_lineage.png) 
*Figure 31: The lineage map showcasing the flow of data from raw S3 CSV to processed outputs.*

---


## 7. Activities and Exercises

### Activity 1: Comprehensive Analysis of Outliers and Correlations
1. Navigate back to your completed Data Profile Job and open the **Correlations matrix** heatmap.
2. Identify which numeric attributes show the strongest positive correlation (closest to `+1.0`) and explain what this correlation implies in the context of pandemic tracking.
3. Click the **Column statistics** tab and inspect the metric results for the `positive` column.
4. Identify the number of outliers detected. Write a brief paragraph discussing how outliers are calculated (hint: standard deviation threshold) and how outliers affect machine learning prediction models if left untreated.

### Exercise 1: Custom Recipe Expansion (Data Standardizing)
1. Re-open your `covid-data-analysis` project.
2. Data preparation frequently requires standardizing text fields. Let's practice standardizing the `state` column.
3. Locate the `state` column. Click the **three dots (...)** -> **Format** -> **To uppercase**.
4. Apply the change. Notice that a new step is added to your local project recipe.
5. Add another transformation to standardise the `hash` column: identify missing values in the `hash` column and replace them with a default string `"UNKNOWN"`.
6. Publish this updated recipe as **Version 2.0**.

### Exercise 2: Defining a Data Quality Ruleset
1. In the AWS Glue DataBrew console, select your dataset `states-daily` and click the **Data quality rules** tab.
2. Click **Create ruleset**.
3. Create a custom rule named `CheckPositiveCases` that validates that the values in the `positive` column must always be greater than or equal to `0` (non-negative cases constraint).
4. Click **Run data quality ruleset** and monitor the results in CloudWatch Logs or the DataBrew console.

---

## 8. Expected Outputs / Results Verification
Upon successful completion of both sessions, you must verify the following outputs in your AWS environment:

1. **Glue DataBrew Project Portal:** An active project named `covid-data-analysis` configured with 500-row sampling.
2. **Published Recipes:** An active recipe named `covid-states-daily-recipe` showing at least 10 executed steps, successfully published as **Version 1.0** (or Version 2.0 if you completed Exercise 1).
3. **Data Profile Report:** A completed profile job showing statistical summaries and correlations for up to 20,000 scanned records.
4. **S3 Partition Structures:** Your target S3 bucket must contain nested folders organized precisely as `job-outputs/year=YYYY/month=MM/day=DD/`. Each leaf folder must contain an optimized CSV file.

---


## 9. Troubleshooting and Best Practices

### Troubleshooting Common Issues
* **Compute Provisioning Timeout:** If your interactive session gets stuck on "Provisioning compute," close your tab, clear your browser cache, and re-open the project. DataBrew interactive sessions automatically terminate after 30 minutes of inactivity to save costs.
* **Access Denied / S3 Write Errors:** If your profiling or recipe jobs fail with permissions issues, ensure that your S3 bucket name matches your IAM service role policy. The pre-configured role `DataBrewLabRole` is scoped to access buckets starting with the prefix `databrew-lab-` or those specified in your CloudFormation Outputs.
* **Incorrect Column Names After Splitting:** If your S3 output files are not partitioned correctly, verify that you renamed your split columns to `year`, `month`, and `day`. If you leave the columns named `date_copy_1` or `date_copy_2_1`, the partitioning parameters in your job settings will fail.
* **IAM Policy Latency:** When creating a new IAM role, AWS might take up to 60 seconds to propagate policies across all services. If your project fails to load immediately after creation, wait 1 minute and refresh the page.

### Best Practices for AWS Glue DataBrew
* **Always Start with Profiling:** Before applying any cleansing transformations, always run a Profile Job. Profiling provides a high-level blueprint of your dataset, highlighting anomalies, null percentages, and data quality issues that you might otherwise miss.
* **Leverage Sampling Wisely:** Interactive project sessions use samples (500 or 1,000 rows) to keep the UI fast and responsive. Always design and test your recipes on these samples first, then run a Recipe Job to apply the steps across your entire multi-gigabyte dataset.
* **Avoid Infinite Loops / S3 Recursion:** Never configure a recipe job to output its results to the same S3 directory that contains your source raw files. This can trigger infinite data cycles, reprocessing the output files as raw input, resulting in high computing costs.
* **Automate Recurrent Cleaning with Schedules:** For production workloads, configure your recipe jobs to run on a set schedule (e.g., daily or weekly). This ensures that newly uploaded raw data is automatically cleaned and partitioned without manual intervention.
* **Delete Unused Resources:** S3 storage, profiling jobs, and projects incur charges over time. To avoid unnecessary AWS bills, always empty and delete your S3 output folders, delete your DataBrew projects, and delete your published recipes once the academic lab is graded.

---

## 10. Summary
In this lab, you successfully transformed a raw COVID-19 tracking dataset into a clean, structured, and query-optimized data lake model using AWS Glue DataBrew. You connected to S3 data sources, discovered data anomalies using automated profiling, designed a 10-step cleansing recipe, and deployed a scalable Apache Spark job to process and dynamically partition data in S3 by year, month, and day. By implementing these techniques, you have mastered one of the most critical phases of the cloud data engineering pipeline—preparing messy raw data for high-performance analytics.

---


## 11. Review Questions

### Student Review Questions (with Answers)

#### Q1: What is the difference between an AWS Glue DataBrew "Profile Job" and a "Recipe Job"?
* **Answer:** A **Profile Job** is a diagnostic tool that scans the raw dataset to generate a detailed Data Quality report (summarizing row/column count, null rates, correlations, and outliers) without modifying the data. A **Recipe Job** is an execution pipeline that applies your published, step-by-step transformations (the recipe) to the entire dataset, generating clean, formatted output files at a target S3 location.

#### Q2: Why is "S3 Data Partitioning" crucial for big data query engines like Amazon Athena?
* **Answer:** Partitioning segment files into logical folders (e.g., by year, month, and day) in S3. When query engines search this data, they use partition pruning to scan only the sub-directories matching the query criteria instead of reading every file in the bucket. This dramatically reduces query execution times and lowers costs, as AWS Athena charges based on the volume of data scanned.

#### Q3: What is the "Principle of Least Privilege," and how is it applied in our DataBrew setup?
* **Answer:** The Principle of Least Privilege dictates that a service should only be granted the minimum permissions required to perform its tasks. In this lab, we configure an **IAM Service Role** that restricts DataBrew to read-only access on the input S3 bucket, read/write access to the output bucket, and write access to CloudWatch Logs, preventing unauthorized changes to other AWS resources.

#### Q4: Why must the `date` column be converted from an integer to a string before splitting?
* **Answer:** Splitting columns relies on string-manipulation functions (such as indexing characters at specific positions). If a column is formatted as an integer, string-manipulation operations cannot be executed. Converting the type to string allows the engine to accurately parse and split the characters.

#### Q5: Under what circumstances would you use "Categorical Mapping" on a dataset?
* **Answer:** Categorical Mapping is used when a column contains non-numeric text labels (like grades `A+`, `B`, or regions `North`, `South`) that represent categories. Standardizing these into a numeric ordinal scale allows analytical tools, charts, and machine learning models to plot, sort, and calculate mathematical correlations between fields.

#### Q6: Explain what "Data Lineage" represents in AWS Glue DataBrew.
* **Answer:** Data Lineage is a visual flowchart that traces the origin, movement, and transformations of your data. It displays the raw S3 source file, the dataset definition, the project containing recipe steps, and the final output files, enabling auditability and tracking of your data pipeline.

#### Q7: Why is "Sampling" used in DataBrew projects instead of processing the entire dataset?
* **Answer:** Processing massive datasets (gigabytes or terabytes) in real-time during interactive visual development is computationally expensive and slow. By loading a small sample (like 500 rows), DataBrew provides a highly responsive, spreadsheet-like interface for designing and previewing your transformations instantly.

#### Q8: What pricing tier features are available for AWS Glue DataBrew?
* **Answer:** AWS Glue DataBrew offers a **Free Tier of 40 hours of interactive session time** per month. Beyond the free tier, interactive sessions are billed per session, and jobs are billed per node-hour using Data Processing Units (DPUs).
