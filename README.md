# MyTodoList SpringBoot backend  

#### To compile:
Assuming we're using the "maven" profile:
```
mvn -P maven install
```
#### To run locally:
```
java -Doracle.jdbc.diagnostic.permitSensitiveDiagnostics=true -Doracle.jdbc.diagnostic.enableSensitiveDiagnostics=true -Dserver.port=8181 -jar ./target/mytodolist-0.0.1-SNAPSHOT.jar
```

#### List items:
```
% curl -s http://localhost:8181/todolist | json_pp
[
   {
      "createdAt" : "2023-06-08T10:10:55.765022Z",
      "description" : "prepare demo",
      "done" : false,
      "id" : 1
   }
]
```
Or
```
curl -s https://mytodolist1.orcl.dev/todolist | json_pp
```
#### Add item:
```
% curl -X POST http://localhost:8181/todolist -H 'Content-Type: application/json' -d '{"description":"another item"}'
```
Or
```
curl -X POST https://mytodolist1.orcl.dev/todolist -H 'Content-Type: application/json' -d '{"description":"another item"}' 
```

#### Delete item #1:
```
% curl -X DELETE http://localhost:8181/todolist/1 
```


#### Update item #3:
```
% curl -X PUT http://localhost:8181/todolist/3 -H 'Content-Type: application/json' -d '{"done": true}'
```