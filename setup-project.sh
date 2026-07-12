#!/bin/bash

# Exit if any command fails
set -e

echo "Creating project directory structure..."

# Create directories
mkdir -p src/main/java/com/demo
mkdir -p src/test/java/com/demo
mkdir -p scripts

# Create project files
touch Dockerfile
touch Jenkinsfile
touch pom.xml
touch VERSION
touch README.md

# Create script files
touch scripts/deploy.sh
touch scripts/rollback.sh
touch scripts/healthcheck.sh

# Create Java source files
touch src/main/java/com/demo/App.java
touch src/test/java/com/demo/AppTest.java

# Make shell scripts executable
chmod +x scripts/*.sh

echo "======================================"
echo " Project structure created successfully!"
echo "======================================"

# Display the directory structure
tree .
