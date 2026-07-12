# Jenkins Dockerized CI/CD Demo

## Project Overview

This project demonstrates a complete CI/CD pipeline using Jenkins, Maven, Docker, and Shell scripting.

## Pipeline Stages

- Checkout
- Build
- Test
- Package
- Docker Build
- Deploy
- Health Check
- Rollback

## Project Structure

```
jenkins-dockerized-ci-cd/
├── src/
│   ├── main/
│   └── test/
├── scripts/
│   ├── deploy.sh
│   ├── rollback.sh
│   └── healthcheck.sh
├── Dockerfile
├── Jenkinsfile
├── pom.xml
├── VERSION
└── README.md
```

## Technologies Used

- Jenkins
- Git & GitHub
- Maven
- Docker
- Shell Scripting
- Java

## Build

```bash
mvn clean package
```

## Docker Build

```bash
docker build -t jenkins-demo:1.0.0 .
```

## Run Container

```bash
docker run -d -p 8080:8080 --name jenkins-demo jenkins-demo:1.0.0
```

## Version

Current Version:

```
1.0.0
```

## Author

Dharmendra Sahoo
