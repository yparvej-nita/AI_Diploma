# CSCI-430: Cloud Computing for Data Science
## LAB MANUAL: WEEK 12

# LAB 12: Machine Learning with AWS SageMaker Canvas
 
**Document Classification:** Student & Instructor Lab Guide 


---

## Table of Contents
1. [Introduction](#1-introduction)
2. [Learning Objectives](#2-learning-objectives)
3. [Prerequisites](#3-prerequisites)
4. [Background Theory](#4-background-theory)
 - 4.1 [What is Amazon SageMaker?](#41-what-is-amazon-sagemaker)
 - 4.2 [Amazon SageMaker Canvas: No-Code ML Democratization](#42-amazon-sagemaker-canvas-no-code-ml-democratization)
 - 4.3 [Regression vs. Classification in Supervised Learning](#43-regression-vs-classification-in-supervised-learning)
 - 4.4 [Evaluation Metrics: Generalizing Regression Errors](#44-evaluation-metrics-generalizing-regression-errors)
 - 4.5 [Feature Importance & Column Impact Explained](#45-feature-importance--column-impact-explained)
5. [Step-by-Step Lab Instructions](#5-step-by-step-lab-instructions)
 - [Session 1: AWS SageMaker Canvas Environment Provisioning & Domain Setup](#session-1-aws-sagemaker-canvas-environment-provisioning--domain-setup)
 - [Session 2: Data Ingestion and Dataset Management](#session-2-data-ingestion-and-dataset-management)
 - [Session 3: Model Building, Evaluation, and Prediction](#session-3-model-building-evaluation-and-prediction)
6. [Activities and Exercises](#6-activities-and-exercises)
7. [Expected Outputs / Results Verification](#7-expected-outputs--results-verification)
8. [Troubleshooting and Best Practices](#8-troubleshooting-and-best-practices)
9. [Summary](#9-summary)
10. [Review Questions](#10-review-questions)

---

## 1. Introduction
In the rapidly evolving landscape of data science and cloud-based analytics, machine learning (ML) has transitioned from an experimental research field to a critical operational capability. Traditionally, building predictive models has been a complex process, requiring highly specialized engineering skills. Data scientists and engineers spend significant effort writing complex code in Python or Scala, managing infrastructure, selecting algorithms, tuning hyperparameters, and orchestrating containers. 

To bridge this technical gap and accelerate the lifecycle of business intelligence, AWS introduced **Amazon SageMaker Canvas**. SageMaker Canvas is a fully managed, No-Code visual interface that empowers developers, data scientists, and business analysts to build highly accurate machine learning models without writing a single line of code. By abstracting away the underlying infrastructure and algorithmic complexity, SageMaker Canvas democratizes predictive modeling, allowing domain experts to generate predictions and drive decisions directly from data lakes and S3 buckets.

In this lab, you will learn the end-to-end workflow of no-code machine learning. You will provision an AWS SageMaker Domain, ingest a tabular academic dataset, construct a supervised machine learning model to predict university admission chances, evaluate model performance using advanced regression metrics, run real-time scenarios using batch and single predictions, and enforce cost-management best practices.

---

## 2. Learning Objectives
By the end of this lab, you will be able to:
* **Explain the Pillars of AWS SageMaker:** Understand how the SageMaker suite handles model building, distributed training, one-click hosting, and A/B testing.
* **Define No-Code Machine Learning:** Articulate the benefits of visual ML interfaces and how they compile visual operations into highly scalable AutoML workloads.
* **Provision SageMaker Domains:** Deploy a secure, single-user cloud machine learning environment using the AWS console Quick Setup.
* **Ingest and Validate Datasets:** Connect local or S3-based tabular CSV datasets, and inspect schema structures, records, and types.
* **Build Regression Models:** Identify target columns and train supervised ML models using the "Quick Build" feature.
* **Interpret Model Metrics:** Analyze and interpret regression error evaluation metrics including Root Mean Squared Error (RMSE) and Mean Squared Error (MSE).
* **Evaluate Feature Importance:** Use Column Impact analysis and interactive scatter plots to make model predictions explainable and transparent.
* **Perform Predictive Inference:** Run batch inference on test datasets and modify hypothetical inputs in real-time to generate single predictions.
* **Practice Cloud Cost Controls:** Terminate containerized workspaces using proper logout procedures to eliminate active cloud charges.

---

## 3. Prerequisites
To successfully complete this lab, you must have:
1. **AWS Console Access:** An active AWS Management Console session with permissions to use SageMaker, IAM, S3, and CloudWatch.
2. **Prior Cloud Foundations:** Successful completion of S3 and IAM service role concepts (established in Lab 8, 9, 10, and 11).
3. **University Admissions Dataset:** The graduate admissions CSV dataset file (`Admission_Predict_Ver1.1.csv`) downloaded and ready on your local workstation.
**Resource Download Link:** [Graduate Admissions Dataset](./DSCI-2334-CldComp_DS/week11/states_daily.csv)


---

## 4. Background Theory

### 4.1 What is Amazon SageMaker?
**Amazon SageMaker** is a robust, fully managed machine learning service that equips every developer, data scientist, and business analyst with the capability to build, train, and deploy machine learning models quickly and securely at scale. Historically, building a machine learning model from scratch required setting up physical server clusters, managing deep-learning software libraries, manual hyperparameter optimization, and writing custom inference servers. AWS SageMaker simplifies this entire workflow through five integrated pillars:

1. **Model Building:**
 * **Pre-built Algorithms and Notebooks:** SageMaker includes various pre-optimized, built-in algorithms (e.g., XGBoost, Linear Learner) and sample notebooks, simplifying the exploratory development phase.
 * **Jupyter Notebook Integration:** Jupyter notebooks come pre-installed, offering an integrated development environment (IDE) for rapid coding.
 * **Automatic Model Tuning:** SageMaker uses hyperparameter optimization (HPO) to automatically run multiple training passes with varying parameters to find the most accurate model configuration.
2. **Model Training:**
 * **Managed Training Containers:** SageMaker provisions dedicated EC2 instances pre-configured with popular frameworks (PyTorch, TensorFlow, scikit-learn), executes the training script, and terminates the compute resources immediately upon job completion.
 * **Distributed Training:** SageMaker automatically partitions massive datasets and models across multi-GPU compute clusters, allowing models to scale to billions of parameters.
3. **Model Deployment:**
 * **One-Click Endpoint Deployment:** Allows users to package a trained model and deploy it to a secure, scalable web service endpoint with a single click, providing real-time HTTP predictions.
 * **A/B Testing:** Facilitates testing multiple model versions on live production traffic concurrently to compare accuracies and response times.
4. **Data and Service Integration:**
 * **Enterprise Service Integration:** SageMaker integrates with Amazon S3 (data lakes), Amazon Redshift (data warehouses), and other storage services.
 * **CloudWatch Monitoring:** Integrates with Amazon CloudWatch for extensive monitoring, performance logging, and alerting.
5. **Security and Compliance:**
 * **Role-Based Access Control:** Enforces security policies via AWS Identity and Access Management (IAM), granting fine-grained permissions to files and services.

### 4.2 Amazon SageMaker Canvas: No-Code ML Democratization
While traditional SageMaker workflows require deep programming skills, **Amazon SageMaker Canvas** provides a visual, drag-and-drop workspace that brings predictive power to non-technical users. Behind its simplified visual interface, SageMaker Canvas is backed by **AWS SageMaker Autopilot**, an advanced AutoML technology. 

When you import a dataset and select a target variable, SageMaker Canvas automatically runs a comprehensive AutoML pipeline:
* **Data Quality Verification:** Scans the dataset for missing fields, inconsistent data types, and invalid values.
* **Automated Feature Engineering:** Applies data transformations, imputes missing values, and converts categorical attributes into numeric representations.
* **Algorithm Selection:** Dynamically trains a variety of state-of-the-art machine learning models (e.g., Random Forests, XGBoost, Linear Models, and Neural Networks) in parallel.
* **Hyperparameter Tuning:** Automatically optimizes model parameters to achieve peak accuracy.
* **Model Selection:** Validates all models using robust cross-validation techniques and highlights the best-performing model.

This entire background process is managed serverless-style by AWS, sparing the analyst from server configuration, cluster scaling, or coding.

### 4.3 Regression vs. Classification in Supervised Learning
Supervised learning models are categorized based on the nature of the target column being predicted:
1. **Numeric Prediction (Regression):** Used when the target column is a continuous, numerical variable (e.g., predicting a student's "Chance of Admit" ranging from `0.0` to `1.0`, or a house's value in dollars).
2. **Categorical Prediction (Classification):** Used when the target variable is a discrete category. This includes:
 * *Binary Classification:* Predicting one of two classes (e.g., predicting whether a transaction is "Fraud" or "Legitimate").
 * *Multi-Class Classification:* Predicting one of several classes (e.g., classifying a credit rating as "A", "B", "C", or "D").

In this lab, you will execute a **Numeric Prediction** project to estimate a student's mathematical probability of college admission based on academic profiles.

### 4.4 Evaluation Metrics: Generalizing Regression Errors
When a "Quick Build" of a Numeric Prediction model is complete, SageMaker Canvas evaluates accuracy using two key mathematical regression metrics:

* **Root Mean Squared Error (RMSE):** RMSE measures the standard deviation of residuals (the difference between predicted and actual values). It indicates how far off the model's predictions typically are. For instance, an RMSE of `0.057` means that, on average, the predicted admission chance is within `±0.057` of the actual value.
 $$	ext{RMSE} = \sqrt{rac{1}{N}\sum_{i=1}^{N}(y_i - \hat{y}_i)^2}$$
* **Mean Squared Error (MSE):** MSE calculates the average of the squared prediction errors. By squaring the errors, larger discrepancies are heavily penalized, making this metric ideal for identifying extreme prediction outliers.
 $$	ext{MSE} = rac{1}{N}\sum_{i=1}^{N}(y_i - \hat{y}_i)^2$$

### 4.5 Feature Importance & Column Impact Explained
To provide model transparency and ensure predictions are explainable (avoiding "black box" models), SageMaker Canvas calculates **Feature Importance** (labeled as **Column Impact**). This analysis measures the percentage influence each independent feature (e.g., CGPA, GRE Score) exerts on the final target prediction. 

If Cumulative GPA (CGPA) shows a column impact of **39.408%**, it represents that CGPA is the primary mathematical driver behind predicting whether a student gets admitted, followed by secondary variables like GRE Score or TOEFL Score. Interactive scatter plots are generated to show how the target probability correlates with different input ranges.

---

## 5. Step-by-Step Lab Instructions

### Session 1: AWS SageMaker Canvas Environment Provisioning & Domain Setup

#### Step 1: Search for SageMaker Canvas
1. Log in to the **AWS Management Console** using your assigned lab credentials.
2. In the top AWS services search bar, type `Sagemaker Canvas` and select the service to open the console.
3. Ensure you are executing all operations in the **US East (N. Virginia) `us-east-1`** region.

#### Step 2: Create a SageMaker Domain
An active **SageMaker Domain** is a prerequisite for running any user profiles or visual compute instances.
1. On the AWS SageMaker AI console landing page, locate the left-hand navigation pane and click on **Canvas**.
2. Click on the orange **Create Amazon SageMaker domain** button.
3. In the domain configuration page, select the card labeled **Set up for single user (Quick setup)**.
 * *Note:* This quick configuration automatically establishes a new default execution role with standard policies (including the `AmazonSageMakerFullAccess` permission set), establishes internet access, and prepares Studio and Canvas apps.
4. Click the orange **Set up** button to confirm. AWS will automatically start creating the cloud domain, provisioning secure storage, and writing default configurations. This setup takes 2 to 3 minutes to complete.

#### Step 3: Launch the SageMaker Canvas Application Workspace
1. Once the domain creation status changes to a green checkmark and "Active", return to the **Canvas** page on the left sidebar.
2. Under your default user profile, click the button to open the **SageMaker Canvas workspace window**.
3. A new browser tab will launch, displaying a "Provisioning compute" progress circle. During this phase, AWS dynamically spins up a containerized instance of the visual workspace.
4. Wait 1 to 2 minutes for the provisioning progress to hit 100%. Once completed, you will be directed to the **Amazon SageMaker Canvas Home Dashboard**.

---

### Session 2: Data Ingestion and Dataset Management

#### Step 4: Download and Review the Admission Dataset
1. Download the graduate admission dataset from the provided class link:
 * **Dataset Link:** [Graduate Admission Prediction Dataset](https://drive.google.com/file/d/1si6MSBRIeQkLzLyXc3vsWJaLQL38wF7Z/view?usp=sharing)
2. Save the tabular file locally on your workstation as `Admission_Predict_Ver1.1.csv`.
3. Review the dataset structure. The file is a tabular CSV containing **9 columns** and **500 rows**:
 * **Serial No.:** An arbitrary unique record index.
 * **GRE Score:** Graduate Record Examination scores (out of 340).
 * **TOEFL Score:** Test of English as a Foreign Language scores (out of 120).
 * **University Rating:** Ranking of the student's undergraduate institution (on a scale of 1 to 5).
 * **SOP:** Strength of Statement of Purpose (on a scale of 1 to 5).
 * **LOR:** Strength of Letter of Recommendation (on a scale of 1 to 5).
 * **CGPA:** Undergraduate Cumulative Grade Point Average (out of 10).
 * **Research:** Research experience (binary flag: `1` for Yes, `0` for No).
 * **Chance of Admit:** Continuous probability of graduate admission (ranging from `0.34` to `0.94`).

#### Step 5: Import the Tabular File into DataBrew Datasets
1. In your SageMaker Canvas workspace sidebar, click on the **Datasets** icon (database diagram).
2. Click the purple **Import data** dropdown button in the top right and select **Tabular**.
3. In the popup dialog, name your dataset `admission-dataset` and click **Create**.
4. Under the "Select a data source" menu:
 * Select **Local upload**.
 * Click the blue **Select files from your computer** button, browse to locate `Admission_Predict_Ver1.1.csv` on your workstation, and upload it.
5. Once uploaded, verify the file name on the right under the "1 file ready to import" panel and click **Preview dataset**.
6. Canvas will render a preview of the columns and the first few rows. Verify that headers match your CSV, and click **Create dataset**.
7. Your newly created `admission-dataset` should now be visible in your Canvas Datasets list, showing its tabular structure with 9 columns, 500 rows, and 4,500 total cells.

---

### Session 3: Model Building, Evaluation, and Prediction

#### Step 6: Create a New Predictive Model
1. In your SageMaker Canvas workspace sidebar, click on **My Models** (target icon).
2. Click on the purple **+ New Model** button in the top-right corner.
3. In the "Create new model" popup dialog, specify a name:
 * **Model name:** `admission-model`
4. Under "Problem type," select the card for **Predictive analysis** (which predicts tabular values) and click **Create**.

#### Step 7: Configure Dataset and Target Column
1. In the **Select** tab, click the radio button next to your imported `admission-dataset` and click **Select dataset** at the bottom of the page.
2. The Canvas workspace will transition to the **Build** tab, displaying a list of all columns, data types, and missing/mismatched rates.
3. Locate the **Select a column to predict** dropdown search bar in the top-left pane. Search for and select **Chance of Admit**.
4. SageMaker Canvas will automatically analyze the column distribution and select **Numeric prediction** (regression) as its recommended model type.

#### Step 8: Execute Model Quick Build
1. Review the independent variables in the table. Keep all 8 predictive features checked for the initial training.
2. In the right-hand panel, locate the **Quick build** button.
 * *Note:* A Quick Build completes a model build in **2 to 15 minutes** by optimizing feature pathways and selecting best-in-class algorithms. Standard Build runs exhaustive searches, taking 1 to 4 hours.
3. Click the purple **Quick build** button.
4. The canvas page will automatically transition to the **Analyze** tab, displaying progress bars. AWS is spinning up dedicated server resources in the background, conducting feature scaling, training candidate algorithms, and selecting the best model. You can safely leave this tab open or log out; training will run on independent serverless resources.

#### Step 9: Evaluate Model Accuracy and Column Impact Statistics
1. Once the Quick Build is complete (typically in 5 to 7 minutes), Canvas will render the model overview statistics.
2. In the top-left corner under **Model status**, evaluate your error metrics:
 * **RMSE (Root Mean Squared Error):** Note your specific metric (typically around `0.057`). This proves that, on average, the model's predictions are within `±0.057` of the actual admission chance.
 * **MSE (Mean Squared Error):** Note your score (typically around `0.003`), indicating high accuracy and low variance.
3. In the **Overview** tab, analyze the **Column impact** list on the left side of the panel. This list ranks features based on their mathematical importance in predicting graduate admission chances:
 * **CGPA:** Identifies as the dominant predictor, accounting for approximately **39.408%** of the model's prediction weight.
 * **Serial No.:** Surprisingly ranks second at **15.904%** (which indicates a potential data quality issue—serial numbers are arbitrary index IDs and should ideally be excluded to prevent model bias).
 * **GRE Score:** Ranks third at **14.504%**.
 * **TOEFL Score:** Ranks fourth at **9.338%**.
4. Click on **CGPA** in the impact list to view the **Impact of CGPA on prediction of Chance of Admit** scatter plot. Observe how higher CGPA values show a clear, positive correlation with higher admission probabilities.

#### Step 10: Run Scenarios Using Batch Predictions
1. Click the purple **Predict** button in the top-right corner to open the testing interface.
2. Under "Predict target values," select **Batch prediction**.
3. Click **Manual** or **Automatic**, select your testing dataset, and click to run the prediction.
4. Once completed, a preview will display a table containing your input rows alongside a new column labeled **Prediction (Chance of Admit)** (with predicted values like `0.92088` or `0.75342`).
5. Review the batch outputs, verify that the predictions are reasonable based on the input values, and click **Download** to save the predictions locally.

#### Step 11: Terminate Compute Instances via Clean Logout
Because SageMaker Canvas provisions active compute nodes behind the scenes, leaving your workspace running can generate high AWS infrastructure costs. Clean workspace hygiene is mandatory.
1. Once prediction verification is complete, navigate to the bottom-left corner of the Canvas workspace.
2. Click the **Log out** button.
3. A "Log out of Canvas" confirmation dialog will appear, warning you that logging out terminates your workspace instance and stops workspace instance charges.
4. Click **Log out**.
5. Close your Canvas browser tab. Return to your primary AWS Management Console and verify that the SageMaker Domain application dashboard lists your Canvas status as terminated.

---

## 6. Activities and Exercises

### Activity 1: Feature Importance Sensitivity Analysis
1. Navigate back to your completed model's **Analyze** tab and review the **Column impact** rankings.
2. Identify which variables are evaluated as the strongest and weakest drivers of graduate admission chances.
3. Write a brief paragraph discussing the role of **Serial No.** in your model. Given that `Serial No.` is an arbitrary index, why did the model find a **15.904%** impact correlation? (Hint: Consider if the original CSV was pre-sorted by admission chance before indexing, introducing a false chronological correlation).
4. Re-open your model in the **Build** tab, uncheck the box next to **Serial No.** to exclude it from training, and click **Quick Build** again to train a new model version. Compare the new RMSE and feature rankings with your original model.

### Exercise 1: Single Prediction Exploratory Modeling
1. In your model's prediction panel, click on **Single prediction**.
2. Slide the feature inputs to represent the following student profile:
 * **GRE Score:** `337`
 * **TOEFL Score:** `118`
 * **University Rating:** `4`
 * **SOP:** `4.5`
 * **LOR:** `4.5`
 * **CGPA:** `9.65`
 * **Research:** `1` (Yes)
3. Record the generated **Prediction (Chance of Admit)** value.
4. Keep all inputs constant and decrease **CGPA** to `7.50`. Record the updated admission probability.
5. Reset CGPA back to `9.65`, and decrease **GRE Score** to `290`. Record the new admission probability.
6. Compare the two predictions. Identify which academic score reduction resulted in the most dramatic probability drop, and evaluate whether this outcome aligns with the Column Impact list.

---

## 7. Expected Outputs / Results Verification
Upon successful completion of this lab, you must verify the following outputs in your AWS environment:
1. **SageMaker Domain:** An active, configured SageMaker domain under your user profile.
2. **Datasets Panel:** An imported dataset named `admission-dataset` displaying 9 columns, 500 rows, and 4,500 data cells.
3. **Model Overview Dashboard:** A finalized model named `admission-model` showing a completed Quick Build status with `RMSE` around `0.057` and `MSE` around `0.003`.
4. **Column Impact:** A ranked bar chart showing **CGPA** as the primary predictor, with an active CGPA scatter plot showing positive linear correlation.
5. **Prediction Log:** A downloaded batch prediction CSV containing the original features alongside predicted admission probabilities.
6. **Instance Hygiene:** Verified termination of the Canvas container workspace via a clean logout.

---

## 8. Troubleshooting and Best Practices

### Troubleshooting Common Issues
* **Domain Creation Permission Errors:** If domain creation fails with access errors, verify that you are logged in to the AWS Console with full administrator permissions. Quick Setup requires privileges to create IAM roles and write policies.
* **Canvas compute launch gets stuck:** If your launch tab remains stuck on "Provisioning compute" for more than 10 minutes, close your browser tab, log out of AWS, clear browser cookies/cache, log back in, and try to launch the workspace again.
* **Region mismatch errors:** If S3 files do not appear during import, verify that your S3 bucket resides in the **US East (N. Virginia) `us-east-1`** region. SageMaker Canvas cannot connect to data sources in other AWS regions.
* **Quick Build option is greyed out:** If you cannot click "Quick Build," verify that you have chosen a target column and that the target column contains numerical values for numeric predictions.

### Best Practices for AWS SageMaker Canvas
* **Apply Feature Selection:** Never train a model on raw datasets without validating columns. Uncheck ID, index, or unique identifier columns (like `Serial No.`) that do not contain actual predictive signals. This prevents model overfitting and bias.
* **Preprocess Outliers:** Review columns in your Build grid view. Extreme outliers can skew error metrics like RMSE and MSE, reducing the model's accuracy on standard records.
* **Always Terminate Sessions (Cost Control):** Simply closing your browser tab does **not** stop active SageMaker Canvas container charges. You must click **Log out** in the bottom-left corner of the workspace to terminate the underlying compute instances and stop billing.
* **Use Quick Build for Iteration:** Use "Quick Build" to iterate on feature selection, clean up datasets, and test configurations. Save the long-running "Standard Build" for your final model version to maximize accuracy.

---

## 9. Summary
This lab introduced the fundamentals of **No-Code Machine Learning** using **Amazon SageMaker Canvas**. You learned how to provision a SageMaker Domain, import tabular data, configure regression models, and use the "Quick Build" feature to automate feature engineering, model selection, and training. You also learned how to analyze regression metrics (RMSE, MSE) and feature importance to ensure model transparency, use batch/single predictions to evaluate scenarios, and apply workspace cost-control best practices in the cloud.

---

## 10. Review Questions

### Student Review Questions (with Answers)

#### Q1: What is the administrative purpose of setting up a SageMaker Domain?
* **Answer:** A SageMaker Domain serves as a secure, centralized administrative space that manages storage, user profiles, and directory access. It integrates directly with AWS Identity and Access Management (IAM), allowing administrators to enforce role-based access control (RBAC), govern resource provisioning, and manage user environments (like Studio and Canvas) under a single architecture.

#### Q2: How does Amazon SageMaker Canvas abstract the work of a traditional Machine Learning Engineer?
* **Answer:** SageMaker Canvas provides a visual, drag-and-drop workspace that automates the complex steps of the ML pipeline. This includes data quality validation, missing value imputation, categorical encoding, feature selection, parallel training of diverse algorithms, hyperparameter optimization, and serverless model deployment—all without requiring the user to write code.

#### Q3: Why is Root Mean Squared Error (RMSE) considered a "penalizing" metric in regression analysis?
* **Answer:** The formula for RMSE involves squaring the prediction errors (residuals) before averaging them and taking the square root. Squaring the errors means that larger errors have a disproportionately larger impact on the final score than smaller errors. This makes RMSE an excellent metric for identifying and penalizing models with extreme prediction discrepancies.

#### Q4: Explain the risk of keeping an index column like `Serial No.` in your model training dataset.
* **Answer:** Primary keys, serial numbers, or arbitrary record indexes do not contain real predictive features. Keeping them in your dataset can cause the model to establish spurious mathematical correlations based on row ordering or indexing, leading to **overfitting**. This results in high training accuracy but poor performance when predicting on new, unseen data.

#### Q5: Why is it critical to explicitly log out of AWS SageMaker Canvas instead of just closing the browser tab?
* **Answer:** SageMaker Canvas provisions dedicated, containerized cloud computing instances (virtual machines) to run your visual workspace. These instances run continuously and incur hourly charges as long as they are active. Simply closing your browser tab does not terminate the container. You must click **Log out** to stop active compute billing.

#### Q6: What is the difference between "Quick Build" and "Standard Build" in SageMaker Canvas?
* **Answer:** **Quick Build** trains models rapidly (usually in 2–15 minutes) by testing a subset of algorithms, making it perfect for rapid prototyping and feature selection. **Standard Build** executes a exhaustive search across the entire model space, performing deep hyperparameter optimization and feature engineering, which can take 1 to 4 hours but yields the highest accuracy.

#### Q7: What does a Column Impact score of 39% for CGPA indicate about your predictive model?
* **Answer:** It indicates that the undergraduate CGPA is the most influential independent variable, contributing 39% of the mathematical weight when predicting the graduate admission chance. This helps explain model decisions and ensures model explainability.
