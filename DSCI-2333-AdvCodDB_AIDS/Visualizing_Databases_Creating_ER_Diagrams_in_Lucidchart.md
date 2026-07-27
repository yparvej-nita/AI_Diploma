# Lab Instruction Manual: ER Diagram Creation with Lucidchart

**Course:** Database Design and Management

**Lab Title:** Visualizing Databases: Creating ER Diagrams in Lucidchart

**Instructor:** Dr. Yunus Parvej Faiband

**Date:** July 2026

## Lab Overview & Introduction

This lab provides a guided walkthrough for using **Lucidchart** to develop Entity-Relationship (ER) diagrams. As a dedicated tool for database modeling, Lucidchart allows users to illustrate the complex relationships between entities within a system using standard "Crow's Foot" notation This session will cover the entire workflow, from template selection and visual customization to exporting functional SQL code and sharing the final product with stakeholders

## Learning Objectives

By the end of this lab, students will be able to:

* Navigate the Lucidchart dashboard and select appropriate ERD templates  
* Customize entities using advanced shape options, including field counts and shaded headers  
* Establish logical connections between entities using the Connector Tool  
* Export diagram logic into SQL commands compatible with major DBMS platforms  
* Utilize presentation and sharing tools for collaborative review

## Prerequisites

Before beginning the lab, ensure you have the following:

* A computer with a stable internet connection.  
* An active **Lucid account**.  
* **Direct ERD Tool Link:** [https://lucid.co/diagram/erd](https://lucid.co/diagram/erd)  
* *Access Instructions:* If you are a first-time user, click the **sign-up option** and follow the onscreen instructions to create your credentials  
* A basic understanding of database components like entities, attributes, and relationships.

## Step-by-Step Instructions

### Step: Starting a New ER Diagram **Log in** to your account with your credentials On the **main dashboard**, go to the upper left corner and click the **\+ New** button Select **Create from Template** to browse pre-configured options, or choose **Blank Document** to start from scratch In the template search bar, type **"ER"** and press Enter to see options such as *Database ER Diagram*, *Crow's Foot*, or *Colored Entities* Click the **Preview icon** on a template to see if it fits your system requirements, then click **Use Template** to open the builder

**Figure: Screenshot of the Lucidchart Template Gallery with the 'ER' search and 'Use Template' button highlighted**

### Step: Workspace Customization **File Naming:** Click the file name at the top of the screen to rename your project **Adding Visuals:** Use the **Image** section on the left panel to upload icons or logos to make the diagram interactive **Global Styling:** Select the background and choose a color that reflects your brand (e.g., Aqua or Purple)

### Step: Configuring Entities and Shapes

* Navigate to the **Shape button** on the left panel, search for "ER," and drag the desired entity shapes onto the canvas  
* Select an entity and use the **Advanced Options** menu:  
* **Fields:** Adjust the count (e.g., set to one or three fields)  
* **Headers:** Toggle the **Shaded Header** option  
* **Colors:** Set specific colors for the header or use **Alternate Rows** for better data readability  
* **Custom Data:** To add specific property types, go to the **Data** section and click **Add New Field**

**Figure: Screenshot of the Advanced Options panel showing field adjustments and 'Alternate Rows' settings**

### Step: Building Relationships Open the **Shapes panel** and search for the **Connector Tool** Drag and drop connectors between the entities you have created Ensure the connections logically represent the relationships within your database system

## SQL Entity Blocks

Lucidchart allows users to bridge the gap between visual design and technical implementation by exporting to SQL

### Exporting ER to Code Click the **Export ER** button Select your target system: **MySQL, SQL Server, Oracle, or Quickbase** Copy the generated commands to your clipboard *Technical Note:* While the tool generates the core structure, you may need to manually refine specific data types or foreign keys in your final script

**Example SQL Output:**  
\-- Generated table structure for a 'Customers' entity  
CREATE TABLE Customers (  
    CustomerID INT PRIMARY KEY,  
    FirstName VARCHAR(100),  
    LastName VARCHAR(100),  
    Email VARCHAR(255)  
);

\-- Generated table structure for an 'Orders' entity  
CREATE TABLE Orders (  
    OrderID INT PRIMARY KEY,  
    OrderDate DATE,  
    CustomerID INT,  
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)  
);

## Activities and Tasks

### Task: Retail Schema Creation

Build an ER diagram for a retail database containing three entities: Customers, Products, and Sales.

* Assign at least three fields to each entity  
* Style each entity with a shaded header and alternate row colors  
* Connect the entities logically using the **Connector Tool**

### Task: Presentation Design Open the **Presentation Builder** Add a new slide and adjust the size so all entities are clearly legible Click **Present Slides** to preview the output as it would appear to a client

## Expected Results

* A professionally styled ER diagram with clear visual hierarchy and branding  
* Accurate logical connections using standard notation  
* Functional SQL code that can be copied into a database management system

## Saving, Sharing, and Publishing

### Saving and Versions

* Lucidchart **Auto-saves** your work, but you can also use **Ctrl \+ S**  
* You can save your diagram as a **Custom Template** with a description for future use

### Sharing and Collaboration

* **Direct Sharing:** Click the **Share** button to invite team members via email. Assign access levels: **Edit, Comment, or View Only**  
* **Links:** Generate a sharable link for social media or email  
* **Exporting:** Go to **File \> Export** to download the diagram as a **PNG, JPEG, SVG, or PDF**  
* **Publishing:** Use the **Publish** option to make the document visible to anyone on the web as a full document or PDF

**End of Lab Manual**  
