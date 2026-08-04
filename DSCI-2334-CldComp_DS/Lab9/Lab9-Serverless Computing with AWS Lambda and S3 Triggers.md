# Lab 9: Serverless Computing with AWS Lambda

**Course:** Cloud Computing for Data Science**Date:** August 11, 2026

## 1\. Introduction

This lab explores the paradigm of **serverless computing** using **AWS Lambda**. Serverless computing allows developers to build and run applications without the burden of managing underlying infrastructure. In this session, you will create a Lambda function that automatically responds to events in an Amazon S3 bucket, demonstrating the power of event-driven architectures for data science workflows.

## 2\. Learning Objectives

By the end of this lab session, you will be able to:

* Define serverless computing and its core benefits.  
* Create and configure an **AWS Lambda function** using Python.  
* Implement **IAM (Identity and Access Management)** roles to grant secure access between services.  
* Configure **Amazon S3 triggers** to invoke Lambda functions automatically.  
* Monitor and troubleshoot serverless applications using **Amazon CloudWatch**.

## 3\. Prerequisites

* An active **AWS Management Console** account.  
* Successful completion of **Lab 8** (S3 Bucket Management).  
* Basic familiarity with Python programming and JSON data structures.

## 4\. Background Theory

### 4.1 Serverless Computing & AWS Lambda

AWS Lambda is a serverless compute service that runs your code in response to triggers and automatically manages the underlying compute resources. Key features include:

* **No Infrastructure Management:** AWS handles server provisioning, patching, and scaling.  
* **Automatic Scaling:** Lambda scales precisely with the number of incoming events.  
* **Pay-Per-Use:** Charges are based only on the number of requests and the execution time (duration) of your code.  
* **Event-Driven:** Functions are triggered by events such as HTTP requests via API Gateway, object uploads in S3, or changes in DynamoDB.

### 4.2 IAM Roles and Permissions

Security in AWS is governed by the **Principle of Least Privilege**. For a Lambda function to interact with other services, such as reading a file from S3, it must be assigned an **Execution Role** with specific permissions.

### 4.3 Amazon CloudWatch

CloudWatch provides monitoring and observability for AWS resources. For Lambda, it automatically captures logs (via CloudWatch Logs) and performance metrics, such as invocation counts and execution duration, which are essential for debugging serverless logic.

## 5\. Lab Instructions

### Step 1: Create an Amazon S3 Bucket

1. Log in to the AWS Console.  
2. Search for and navigate to the **S3** service.  
3. Click **Create bucket** and provide a unique name, such as myvideostore-\[your-name\].  
4. Leave other settings as default and click **Create bucket**.

**Insert Screenshot of S3 bucket creation success page***Figure 1: Successfully created S3 bucket ready for event triggers.*

### Step 2: Initialize the Lambda Function

1. Open a new browser tab and navigate to the **Lambda** dashboard.  
2. Click **Create function**.  
3. Choose **Author from scratch**.  
4. **Function name:** myVideoStoreFunction.  
5. **Runtime:** Select **Python 3.13** (or the latest available version).

**Insert Screenshot of Lambda "Basic information" section***Figure 2: Setting the function name and Python runtime environment.*

### Step 3: Configure Permissions (2026 UI Workflow)

AWS has simplified the Lambda console. Follow these steps to grant the necessary permissions:

1. In the **Permissions** section of the creation page, select **Create a new role with basic Lambda permissions**.  
2. Click **Create function**.  
3. Once the function is created, navigate to the **Configuration** tab and select **Permissions** on the left sidebar.  
4. Under **Execution role**, click the blue **Role name** link. This will open the IAM Console in a new tab.  
5. In the IAM Console, click **Add permissions** and select **Attach policies**.  
6. Search for **AmazonS3ReadOnlyAccess**, check the box next to it, and click **Add permissions**.

### Step 4: Write and Deploy the Lambda Code

1. In the Lambda function editor (Code tab), replace the default code with the following script:

```python
import json
import urllib.parse
import boto3

print('Loading function')

s3 = boto3.client('s3')


def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        print("CONTENT TYPE: " + response['ContentType'])
        return response['ContentType']
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e

```
1. Click the **Deploy** button to save and activate your code.

**Insert Screenshot of Lambda code editor with code deployed***Figure 3: Python code implemented in the Lambda editor.*

### Step 5: Add an S3 Trigger

1. Scroll to the **Function overview** section at the top of the Lambda page and click **\+ Add trigger**.  
2. Select **S3** from the source dropdown.  
3. **Bucket:** Select the bucket you created in Step 1\.  
4. **Event types:** Select **All object create events**.  
5. Scroll down, check the **Recursive invocation acknowledgment** box, and click **Add**.

**Insert Screenshot of S3 trigger configuration***Figure 4: Configuring the S3 bucket as an automated trigger.*

## 6\. Testing and Monitoring

### Step 6: Trigger the Function via S3 Upload

1. Navigate back to your **S3 bucket** tab.  
2. Click **Upload** and drag-and-drop a file (e.g., an image or video) into the bucket.  
3. Click **Upload** and wait for the success message.

### Step 7: Verify Execution in CloudWatch

1. Return to your Lambda function and select the **Monitor** tab.  
2. Review the **CloudWatch metrics** to see the invocation count.  
3. Click the **View CloudWatch logs** button.  
4. Select the most recent **Log stream**.  
5. Verify that the log contains the message **CONTENT TYPE:** followed by the format of the file you uploaded.

**Insert Screenshot of CloudWatch Log Events***Figure 5: Log stream showing the successful extraction of file metadata.*

## 7\. Activities and Exercises

* **Activity 1:** Upload a .txt file and then a .jpg file. Compare the log outputs in CloudWatch.  
* **Exercise 1:** Modify the Python code to print the name of the file (the key) in addition to the content type.

## 8\. Expected Outputs

* **S3 Properties:** The "Event notifications" section of your bucket should now show an active link to your Lambda function.  
* **Lambda Permissions:** Under Configuration \-\> Permissions, the **Resource-based policy** should show lambda:InvokeFunction granted to s3.amazonaws.com.  
* **CloudWatch:** A log entry confirming the file upload and its specific content type.

## 9\. Troubleshooting and Best Practices

* **Regional Consistency:** Ensure your S3 bucket and Lambda function are in the **same AWS Region** (e.g., US East (N. Virginia)).  
* **IAM Latency:** Policy changes can take a minute to propagate. If you get an "Access Denied" error, wait 60 seconds and try the upload again.  
* **Avoid Recursive Loops:** Never configure a Lambda function to write back to the same S3 bucket that triggers it unless you use specific filters (like prefixes), as this can cause an infinite loop of executions.  
* **Cleanup:** To avoid charges, **Delete the Lambda function** and **Delete the S3 bucket** once the lab is complete.

## 10\. Summary

This lab demonstrated the fundamental principles of **event-driven architecture**. By creating a Lambda function that triggers automatically upon an S3 upload, you have built a scalable, serverless solution for data processing. You also learned how to manage cross-service permissions using IAM and how to use CloudWatch for operational visibility.

## 11\. Review Questions

1. Explain the difference between "Author from scratch" and "Use a blueprint" when creating a Lambda function.  
2. Why did we need to add AmazonS3ReadOnlyAccess to the Lambda execution role?  
3. What is a "trigger" in the context of serverless computing?  
4. Which service allows you to see the output of print() statements in your Lambda code?  
5. True or False: You have to pay for AWS Lambda even when the function is not running. Explain your answer.

