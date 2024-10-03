# Todolist SpringBoot 3 backend

Todolist application backend built with Spring Boot 3, using Oracle JDBC.

- __App Version `v2.0.0`__
- __Oracle JDBC Version `v23.4.0.24.05`__
- __Spring Boot Version `v3.3.3`__
- __Java Version `17`__

This application also serves a frontend application using React.
- __App Version `v1.0.1`__
- __Node Version `v22.8.0`__
- __NPM Version `10.8.2`__


## Environment Variables
The following environment variables are expected by the application.
In order to successfully run the application, the required environment variables below are marked and some are optional:

| Variable                        | Required | Name                            | Default     | Description                                                     |
|---------------------------------|:--------:|---------------------------------|-------------|-----------------------------------------------------------------|
| `DATABASE_URL`                  |   Yes    | Database URL                    | -           | Connection to URL, in the form of `jdbc:oracle:thin:@<details>` |
| `DATABASE_USER`                 |   Yes    | Database User                   | -           | Database user with access to the necessary tables               |
| `DATABASE_PASSWORD`             |   Yes    | Database Password               | -           | Database user credentials                                       |
| `SPRING_SECURITY_USER_NAME`_    |          | Spring Security Name            | user        | Sets basic authentication username                              |
| `SPRING_SECURITY_USER_PASSWORD` |          | Spring Security Password        | <generated> | Sets basic authentication password                              |
| `ORACLE_JDBC_CONFIG_FILE`       |          | Connection Property config File | -           | Specifies the path of a connection properties file<sup>A</sup>  |
<sup>A</sup> Environment variable overriding the default file location of the [Connection Properties file](https://docs.oracle.com/en/database/oracle/oracle-database/23/jajdb/oracle/jdbc/OracleConnection.html#CONNECTION_PROPERTY_CONFIG_FILE).

## API Endpoints
The following endpoints are endpoints used by the application.

| Method | REST Endpoint                             | Sample Data                            | Description           |
|--------|-------------------------------------------|----------------------------------------|-----------------------|
| GET    | `http://localhost:8080/api/todolist`      | -                                      | Retrieves all Todos   |
| POST   | `http://localhost:8080/api/todolist`      | `{"description" : "Second new task!"}` | Saves a new Todo      |
| GET    | `http://localhost:8080/api/todolist/{id}` | -                                      | Retrieves a Todo item |
| PUT    | `http://localhost:8080/api/todolist/{id}` | `{"description": "...", "done": true}` | Updates a Todo item   |
| DELETE | `http://localhost:8080/api/todolist/{id}` | -                                      | Deletes a Todo item   |

The following addresses are also used by the frontend application.

| Endpoint                           | Description                                          |
|------------------------------------|------------------------------------------------------|
| `http://localhost:8080/api/health` | Health check endpoint; auth not required. Returns OK |
| `http://localhost:8080/login`      | Login Endpoint                                       |
| `http://localhost:8080/`           | React Application                                    |
| `http://localhost:8080/logout`     | Logout Endpoint                                      |

## SQL Schema, Tables and Queries

The application expects and makes use of the following:

- __Database Schemas__: `TODOOWNER`
- __Database Tables__: `TODOITEM`
- __Database Queries and Privilege__:
    - `select, insert, update, delete` on `TODOOWNER.TODOITEM`


# Building the Application
The application uses Maven to build and manage the project with its dependencies.
Since the [Dockerfile](./Dockerfile) expects the JAR, you need to run mvn first.
```bash
mvn clean package
```

When building for docker, you can use the following command:
```bash
docker build -t example:v1 .
```

# Deploying to Kubernetes
To deploy the application on Kubernetes,
the environment variables and image must be replaced.

For example, you can create the following manifest.yaml file:
```yaml
# manifest
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todolistapp
  labels:
    app: todolistapp
spec:
  selector:
    matchLabels:
      app: todolistapp
  replicas: 2
  template:
    metadata:
      labels:
        app: todolistapp
        version: v1
    spec:
      containers:
        - name: todolistapp-springboot
          image: example:v1 # update with your container image
          imagePullPolicy: Always
          env:
            - name: DATABASE_URL
              value: "jdbc:oracle:thin:@<details>" # update with your database URL
            - name: DATABASE_USER
              value: "TODOUSER" # update with your database user
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: credentials # update with your secret
                  key: dbpassword

            - name: SPRING_SECURITY_USER_NAME
              valueFrom:
                secretKeyRef:
                  name: credentials # update with your secret
                  key: uiusername
                  optional: true
            - name: SPRING_SECURITY_USER_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: credentials # update with your secret
                  key: uipassword
              
          ports:
            - containerPort: 8080
              
          # if database wallet is required
          volumeMounts:
            - name: creds
              mountPath: /mtdrworkshop/creds # update with the right path to the wallet
          # end if

      # if database wallet is required
      volumes:
        - name: creds
          secret:
            secretName: db-wallet-secret # update with the actual secret
      # end if
      
      restartPolicy: Always 
---

apiVersion: v1
kind: Service
metadata:
  name: todolistapp
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: todolistapp
  
  # sticky session used for in-memory sessions
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 600
```

This configuration requires the following secret to be created:
```bash
kubectl create secret generic credentials \ 
--from-literal=dbpassword=<value> \
--from-literal=uiusername=<value> \
--from-literal=uibassword=<value>
```

If a wallet is necessary, you can run the following command to create the wallet secret
```bash
kubectl create secret generic wallet --from-file=<wallet_location>
```