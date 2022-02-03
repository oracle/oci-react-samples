# Backend

## Introduction

In this lab, you will deploy the pre-built Helidon Java backend Docker image to OKE, then configure the API Gateway.

Estimated time: ~25-minutes.

### Objectives

* Build and deploy the Docker image of the application
* Deploy the image on the Oracle Kubernetes Engine (OKE)
* Describe the steps for Undeploying
* Configure the API Gateway
* Test the backend application

### Prerequisites

This lab requires the completion of lab 1 and the provision of the OCI components.

### Understanding the Java/backend application

As with most React applications (https://reactjs.org/), this application uses remote APIs to handle data persistence. The backend implements 5 REST APIs including:
- Retrieving the current list of todo items
- Adding a new todo item
- Finding a todo item by its id
- Updating an existing todo item
- Deleting a todo item.

The APIs are documented using Swagger @ http://130.61.67.158:8780/swagger-ui/#/

The backend is implemented using the following Java classes (under ./backend/src/...):   
- Main.java: starts and configure the main entry points.
- ToDoItem.java: maps a Todo Item instance to/from JSON  document
- ToDoItemStorage.java: stores the Todo item in a persistent store i.e., the Oracle Autonomous database
- ToDoListAppService.java: implements the Helidon service and exposes the REST APIs

  ![](images/Backend-APIs.png " ")

## **Task 1**: Build and push the Docker images to the OCI Registry

1. Edit ./backend/src/main/java/com/oracle/todoapp/Main.java

    - Locate the following code fragment

    ![](images/CORS-Main.png " ")
    - Replace `eu-frankfurt-1` in  `"https://objectstorage.eu-frankfurt-1.oraclecloud.com"` by your region

    - Save the file

2. Run `build.sh` script to build and push the helidon-se image into the repository

    ```
    <copy>cd $MTDRWORKSHOP_LOCATION/backend; ./build.sh</copy>
    ```
  In a couple of minutes, you should have successfully built and pushed the images into the OCIR repository.

3. Check your container registry in your compartment
    - Go to the Console, click the hamburger menu in the top-left corner and open
    **Developer Services > Container Registry**.
   
   ![](psong_images/container_registry.png)

## **STEP 2**: Deploy on Kubernetes and Check the Status

1. Run the `deploy.sh` script

  ```
  <copy>cd $MTDRWORKSHOP_LOCATION/backend; ./deploy.sh</copy>
  ```

--> service/todolistapp-helidon-se-service created
--> deployment.apps/todolistapp-helidon-se-deployment created

2. Check the status using the following commands
$ kubectl get services

The following command returns the Kubernetes service of MyToDo application with a load balancer exposed through an external API
  ```
  <copy>kubectl get services</copy>
  ```

![](images/K8-service-Ext-IP.png " ")

3. $ kubectl get pods
  ```
  <copy>kubectl get pods</copy>
  ```

![](images/k8-pods.png " ")

5. Continuously tailing the log of one of the pods

  $ kubectl logs -f <pod name>
  Example kubectl lgs -f todolistapp-helidon-se-deployment-7fd6dcb778-c9dbv

  Returns:
  http://130.61.66.27/todolist

## **STEP 4**: UnDeploy (optional)

  If you make changes to the image, you need to delete the service and the pods by running undeploy.sh then redo Steps 2 & 3.

  1. Run the `undeploy.sh` script
  ```
    <copy>cd $MTDRWORKSHOP_LOCATION/backend; ./undeploy.sh</copy>
  ```
  2. Rebuild the image + Deploy + (Re)Configure the API Gateway


## **STEP 5**: Configure the API Gateway

The API Gateway protects any RESTful service running on Container Engine for Kubernetes, Compute, or other endpoints through policy enforcement, metrics and logging.
Rather than exposing the Helidon service directly, we will use the API Gateway to define cross-origin resource sharing (CORS).

1. From the hamburger  menu navigate **Developer Services** > **API Management > Create Gateway**
   ![](images/API-Gateway-menu.png " ")

2. Configure the basic info: name, compartment, VCN and Subnet
    - VCN: pick on of the vitual circuit network
    - Subnet pick the public subnet   
    The click "Create"
  ![](images/Basic-gateway.png " ")

3. Click on Todolist gateway
       ![](images/Gateway.png " ")

4. Click on Deployments
   ![](images/Deployment-menu.png " ")

5. Create a todolist deployment
   ![](images/Deployment.png " ")


6. Configure Cross-origin resource sharing (CORS) policies.
  - CORS is a security mechanism that will prevent running application loaded from origin A  from using resources from another origin B.
  - Allowed Origins: is the list of all servers (origins) that are allowed to access the API deployment typically your Kubernetes cluster IP.
  - Allowed methods: GET, PUT, DELETE, POST, OPTIONS are all needed.
    ![](images/Origins-Methods.png " ")

7. Configure the Headers
    ![](images/Headers.png " ")

8. Configure the routes: we will define two routes:
    - /todolist for the first two APIs: GET, POST and OPTIONS
    ![](images/Route-1.png " ")

    - /todolist/{id} for the remaining three APIs: (GET, PUT and DELETE)
    ![](images/Route-2.png " ")


## **STEP 6**: Testing the backend application through the API Gateway

1. Navigate to the newly create Gateway Deployment Detail an copy the endpoint
   ![](images/Gateway-endpoint.png " ")

2. Testing through the API Gateway endpoint
  postfix the gateway endpoint with "/todolist" as shown in the image below
   ![](images/Backend-Testing.png " ")

  It should display the Todo Item(s) in the TodoItem table. At least the row you have created in Part I.

Congratulations, you have completed lab 2; you may now [proceed to the next lab](#next).

## Acknowledgements

* **Author** -  - Kuassi Mensah, Dir. Product Management, Java Database Access
* **Contributors** - Jean de Lavarene, Sr. Director of Development, JDBC/UCP
* **Last Updated By/Date** - Kuassi Mensah, Database Product Management,  April 2021
