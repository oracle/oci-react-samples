## CloudBank Frontend
This Spring-Boot microservice is deployable on Oracle Kubernetes Engine (OKE) and 
serves a React frontend. With `frontend-maven-plugin`, the React files are built as HTML files. With the `maven-resources-plugin`, the HTML files are then placed inside the output directory.

## POM/Requirements Breakdown
### Properties
```XML
    <properties>
        <!-- React frontend application directory (source files) -->
        <frontend-src-dir>${project.basedir}/src/main/react-app</frontend-src-dir>
        <node.version>v16.13.1</node.version>
        <npm.version>v8.1.2</npm.version>
        <frontend-maven-plugin.version>1.7.6</frontend-maven-plugin.version>
        <java.version>11</java.version>
    </properties>
```

### Dependencies
```XML
    <dependencies>
        <!-- Required -->
        <!-- Allows us to add the default Auth LoginPage -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <!-- Required -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
```

### Plugins
```XML
            <plugin>
                <groupId>com.github.eirslett</groupId>
                <artifactId>frontend-maven-plugin</artifactId>
                <version>${frontend-maven-plugin.version}</version>

                <configuration>
                    <nodeVersion>${node.version}</nodeVersion>
                    <npmVersion>${npm.version}</npmVersion>
                    <workingDirectory>${frontend-src-dir}</workingDirectory>
                    <installDirectory>${project.build.directory}</installDirectory>
                </configuration>

                <executions>
                    <!-- Installs Node and NPM for building the app -->
                    <!-- As stated in the plugin documentation, the node and npm -->
                    <!-- installed by the plugin is not meant to replace or provide -->
                    <!-- production node installations and only serves to build apps-->
                    <execution>
                        <id>install-frontend-tools</id>
                        <goals>
                            <goal>install-node-and-npm</goal>
                        </goals>
                    </execution>

                    <!-- Install application dependencies -->
                    <execution>
                        <id>npm-install</id>
                        <goals>
                            <goal>npm</goal>
                        </goals>
                        <configuration>
                            <arguments>install</arguments>
                        </configuration>
                    </execution>

                    <!-- Build application -->
                    <execution>
                        <id>npm run build</id>
                        <goals>
                            <goal>npm</goal>
                        </goals>
                        <configuration>
                            <arguments>run build</arguments>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-resources-plugin</artifactId>
                <version>3.2.0</version>
                <executions>
                    <!-- Copies build files files inside the output directory -->
                    <execution>
                        <id>position-react-build</id>
                        <goals>
                            <goal>copy-resources</goal>
                        </goals>
                        <phase>prepare-package</phase>
                        <configuration>
                            <outputDirectory>${project.build.outputDirectory}/static</outputDirectory>
                            <resources>
                                <resource>
                                    <directory>${frontend-src-dir}/build</directory>
                                    <filtering>false</filtering>
                                </resource>
                            </resources>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
```
## Application Code

### Using with React Router
The React application used in this microservice uses React-Router. The frontend shows different components on
`/transfer` and `/transfer/history` endpoints. In order to do this, 
the Spring Boot app implements `WebMvcConfigurer` available:
[here](src/main/java/com/cloudbank/authservice/config/WebMVCConfig.java). Which adds view controllers instructing Spring Boot to keep serving the bundled index.html for these endpoints.

### Making API requests from React


 

### References
[Frontend Maven Plugin](https://github.com/eirslett/frontend-maven-plugin)

[Maven Resources Plugin](https://maven.apache.org/plugins/maven-resources-plugin/)

[Including React in your Spring Boot maven build](https://medium.com/@itzgeoff/including-react-in-your-spring-boot-maven-build-ae3b8f8826e)
