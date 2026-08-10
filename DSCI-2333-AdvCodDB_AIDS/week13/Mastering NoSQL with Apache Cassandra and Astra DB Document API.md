# Lab 13: Learn Apache Cassandra

## 1\. Lab Overview

This laboratory session focuses on **Apache Cassandra**, a high-performance NoSQL database. Instead of traditional SQL management, students will explore managing NoSQL data in the cloud using **DataStax Astra DB**. The lab covers setting up a cloud-based database, generating secure application tokens, and using the **Document API** to interact with the database without a predefined schema.

## 2\. Learning Objectives

By the end of this lab, students will be able to:

* Understand the purpose of DataStax and Astra DB for managed NoSQL services.  
* Deploy a managed Apache Cassandra database and keyspace in the cloud.  
* Generate and manage security tokens for API communication.  
* Utilize the Document API and Swagger UI to perform database operations.  
* Execute HTTP methods (GET, POST, etc.) and interpret server response codes.

## 3\. Prerequisites

To complete this lab, you will need:

* A web browser with internet access.  
* A registered account on the [DataStax Astra DB platform](https://accounts.datastax.com/session-service/v1/login).  
* Basic understanding of JSON data structures.

## 4\. Step-by-Step Procedures

### 4.1 Database Setup on DataStax

DataStax provides tools and services for managing Apache Cassandra, focusing on making NoSQL more accessible through cloud services and developer integrations.

* Log in to your DataStax Astra DB account.  
* Navigate to the **Databases** tab in the sidebar.  
* Click the **Create Database** button.  
* Enter the following configuration details:  
* **Database Name:** cassandra\_db  
* **Keyspace Name:** lets\_learn  
* **Provider:** Google Cloud  
* **Region:** asia-south1  
* Click **Create Database**.  
* **Note:** It may take up to **5 minutes** for the database status to turn to "Active".

Figure 1: Astra DB Create Database interface showing configuration for cassandra\_db*Caption: Configuration for creating the managed NoSQL database.*

### 4.2 Security and Connectivity

To communicate with your database via API, you must generate an application token.

1. Click on **Tokens** in the left-hand sidebar.  
2. In the Role dropdown menu, select **Administrator User**.  
3. Click **Generate Token**.  
4. **Important:** Copy the generated token and save it securely. You will need this for all subsequent API requests.  
5. Navigate to the **Connect** tab in your database dashboard.  
6. Scroll down to the **Select a Method** section, choose **APIs**, and then select **Document API**.  
7. Click the link to **Launch Swagger UI**.

Figure 2: Generating an Administrator Application Token*Caption: Generating the security token required for API authentication.*

## 5\. Activities and Tasks

### 5.1 Creating a Collection and Document

The Document API allows you to store JSON documents in Astra DB without needing to define a schema beforehand.

* In Swagger UI, locate the **POST** endpoint: /v2/namespaces/{namespace}/collections/{collection}.  
* Click **Try it out**.  
* Enter the following Parameters:  
* **namespace:** lets\_learn (This is your Keyspace name).  
* **collection:** events (This is the name of the new collection being created).  
* **X-Cassandra-Token:** Paste your generated token here.  
* In the **Request body** section, enter the following JSON information:

{  
  "location": "Mumbai",  
  "race": {  
    "competitors": 250,  
    "start\_date": "2025-01-15"  
  }  
}

1. Click **Execute**.

### 5.2 Verifying the Data (GET Request)

1. Locate the **GET** endpoint: /v2/namespaces/{namespace}/collections/{collection}.  
2. Enter the namespace (lets\_learn) and collection (events).  
3. Enter your security token in the header field.  
4. Click **Execute**.

## 6\. Expected Results

Upon clicking execute for the GET request, the server should return a status code of **200 (OK)**. The response body will display the JSON data you inserted, along with a unique system-generated document ID.  
{  
  "data": {  
    "8233ab7d-888f-45dc-8403-c82b7b92c5df": {  
      "location": "Mumbai",  
      "race": {  
        "competitors": 250,  
        "start\_date": "2025-01-15"  
      }  
    }  
  }  
}  
Figure 3: Swagger UI showing a successful 200 response code*Caption: Example of a successful server response in the Swagger UI.*

## 7\. Advanced Tools: Hoppscotch

For more advanced API development and testing, you can use **Hoppscotch** (hoppscotch.io). It is a free, open-source platform that makes it easier to interact with various HTTP methods:

* **GET:** Retrieve data from the server.  
* **POST:** Create a new resource on the server.  
* **PUT:** Update or replace an existing resource.  
* **DELETE:** Remove a resource from the server.

**Tip:** To help visualize the meaning of different return codes (like 100, 200, 201, 202), you can visit [httpstatusdogs.com](https://httpstatusdogs.com/).

## 8\. Conclusion

In this lab, you successfully explored the deployment and management of a NoSQL database using Apache Cassandra and DataStax Astra DB. You learned how to bridge the gap between cloud infrastructure and application development using APIs, specifically the Document API. These skills are vital for modern software architecture, where flexible, schema-less data storage and secure API communication are standard practices.  
