# Lab 14: Advanced NoSQL with Apache Cassandra and GraphQL

## 1\. Lab Overview

This laboratory session continues the exploration of **Apache Cassandra** via the **DataStax Astra DB** platform. While previous sessions focused on the Document API, this lab introduces students to interacting with NoSQL databases using **GraphQL API**. Students will learn how to define schemas, create tables, and perform data operations using mutations and queries. Additionally, the lab reinforces the fundamental **HTTP methods** used in modern API communication.

## 2\. Learning Objectives

By the end of this lab, students will be able to:

* Identify the purpose of standard **HTTP methods** (GET, POST, PUT, DELETE).  
* Navigate the Astra DB interface to connect via **GraphQL API**.  
* Utilize the **GraphQL Playground** and its documentation features.  
* Execute **GraphQL Mutations** to create database tables and insert data.  
* Perform targeted **GraphQL Queries** to retrieve specific data fields.  
* Understand the syntax for partition keys and clustering keys in a NoSQL environment.

## 3\. Prerequisites

* An active **DataStax Astra DB** account.  
* The lets\_learn keyspace created in the previous lab.  
* A valid **Application Token** with Administrator permissions.  
* Access to an API testing tool (e.g., Hoppscotch or the Astra DB built-in tools).

## 4\. Fundamental Concepts: HTTP Methods

Before interacting with the database, it is essential to understand the primary methods used to communicate with servers:

* **GET:** Retrieve data from the server.  
* **POST:** Create a new resource on the server.  
* **PUT:** Update or replace an existing resource.  
* **DELETE:** Remove a resource from the server.

## 5\. Step-by-Step Procedures

### 5.1 Verifying Existing Data

Use your preferred API tool to perform a **GET** request to ensure your environment is configured correctly.

1. Set the request type to **GET**.  
2. Enter your Request URL.  
3. Select the **Headers** tab.  
4. Add a new header: X-Cassandra-Token and paste your application token.  
5. Click **Send**.

**Expected Result:**The response body should return the JSON document stored in the previous session (e.g., the Mumbai race data).  
Figure 1: Successful GET request showing JSON response in an API client*Caption: Verifying connection and data retrieval via GET request.*

### 5.2 Connecting via GraphQL API

1. Navigate to your Astra DB dashboard and select your active cassandra\_db.  
2. Click on the **Connect** tab.  
3. Scroll down to the **APIs** section and select **GraphQL API**.  
4. Click on the link for **GraphQL Playground**.

Figure 2: Selecting the GraphQL API connection method in Astra DB*Caption: Switching from Document API to GraphQL API.*

### 5.3 Navigating the GraphQL Playground

Once the Playground launches, you will see a coding interface.

1. Notice the **Docs** tab on the far right of the interface.  
2. Use the **Docs** tab to explore available types, queries, and mutations. This helps you understand the syntax without needing to memorize it.

Figure 3: Using the Docs tab in GraphQL Playground to explore schema details*Caption: The Documentation tab provides real-time syntax assistance.*

## 6\. Activities and Tasks

### Task 1: Creating a Table via Mutation

Unlike the Document API, GraphQL allows you to define a specific structure. Use the following mutation to create a new table called events\_new.

1. In the Playground, ensure you are on the graphql-schema tab.  
2. Enter the following code:

mutation {  
  createTable(  
    keyspaceName: "lets\_learn",  
    tableName: "events\_new",  
    partitionKeys: \[  
      { name: "location", type: { basic: TEXT } }  
    \],  
    values: \[  
      { name: "values", type: { basic: TEXT } }  
    \]  
  )  
}

1. Click the **Play** button to execute.  
2. **Note:** You may need to edit the URL in the Playground to include your keyspace name (e.g., changing the end of the URL to /graphql/lets\_learn).

### Task 2: Implementing a Movie Database Schema

Create two tables to manage a movie catalog: a movies table for basic info and a directors table for relational-style tracking.  
mutation {  
  movies: createTable(  
    keyspaceName: "lets\_learn",  
    tableName: "movies",  
    partitionKeys: \[{ name: "title", type: { basic: TEXT } }\]  
    values: \[{ name: "director", type: { basic: TEXT } }\]  
  )  
  directors: createTable(  
    keyspaceName: "lets\_learn",  
    tableName: "directors",  
    partitionKeys: \[{ name: "name", type: { basic: TEXT } }\]  
    clusteringKeys: \[{ name: "movie\_title", type: { basic: TEXT }, order: "ASC" }\]  
  )  
}

### Task 3: Inserting Data

Add entries to your new movies table using the following mutation.  
mutation {  
  inception: insertmovies(  
    value: { title: "Inception", director: "Christopher Nolan" }  
  ) {  
    value {  
      title  
    }  
  }  
  interstellar: insertmovies(  
    value: { title: "Interstellar", director: "Christopher Nolan" }  
  ) {  
    value {  
      title  
    }  
  }  
}  
Figure 4: Successful execution of data insertion mutations*Caption: Result of inserting Christopher Nolan movies into the database.*

## 7\. Retrieving and Analyzing Data

### 7.1 Data Retrieval Task

Execute a query to fetch the specific details for the movie "Inception".  
query oneMovie {  
  movies(value: { title: "Inception" }) {  
    values {  
      title  
      director  
    }  
  }  
}

### 7.2 Understanding Query Syntax

* **query oneMovie:** Specifies the operation type. The name oneMovie is used for identification and organization.  
* **movies:** This represents the table or resource being accessed.  
* **value: { title: "Inception" }:** This serves as a filter to locate the specific record.  
* **title and director:** These are the specific fields requested from the table. GraphQL only returns the fields you explicitly ask for.

Figure 5: Query result showing retrieved movie information*Caption: The query returns only the title and director for the filtered record.*

## 8\. Conclusion

In this lab, you advanced your NoSQL skills by transitioning from the schema-less Document API to the structured environment of **GraphQL**. You successfully utilized **Mutations** to build a database schema and insert records, and practiced precision data retrieval using **Queries**. These techniques provide a powerful and flexible way to manage data in high-performance Cassandra environments, allowing developers to request exactly what they need and nothing more.  
