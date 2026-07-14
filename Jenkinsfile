pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME     = "jenkins-dockerized-demo"
        IMAGE_TAG      = "1.0.0"
        CONTAINER_NAME = "jenkins-demo"
        HOST_PORT      = "8081"
        CONTAINER_PORT = "8080"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Environment Check') {
            steps {
                sh '''
                echo "======================================"
                echo " Jenkins Build Environment"
                echo "======================================"

                echo ""
                echo "JAVA_HOME = $JAVA_HOME"

                echo ""
                echo "Java Version"
                java -version

                echo ""
                echo "Javac Version"
                javac -version

                echo ""
                echo "Maven Version"
                mvn -version

                echo ""
                echo "PATH"
                echo $PATH
                '''
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package -B'
            }
        }

        stage('Publish Test Results') {
            steps {
                junit '**/target/surefire-reports/*.xml'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Verify Build Artifact') {
            steps {
                sh '''
                echo "Generated JAR Files"
                ls -lh target/

                echo ""
                echo "Dockerfile"
                cat Dockerfile
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                docker images | grep ${IMAGE_NAME}
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker rm -f ${CONTAINER_NAME} || true

                docker run -d \
                    --name ${CONTAINER_NAME} \
                    -p ${HOST_PORT}:${CONTAINER_PORT} \
                    ${IMAGE_NAME}:${IMAGE_TAG}

                docker ps
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                echo "Waiting for application..."

                for i in {1..12}
                do
                    STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:${HOST_PORT} || true)

                    if [ "$STATUS" = "200" ]; then
                        echo "Application is UP"
                        exit 0
                    fi

                    echo "Attempt $i : Application not ready yet..."
                    sleep 5
                done

                echo "Health Check Failed"
                docker logs ${CONTAINER_NAME}
                exit 1
                '''
            }
        }
    }

    post {

        success {
            echo "Build and Deployment Successful."
        }

        failure {
            echo "Pipeline Failed."

            sh '''
            echo "========== Docker Containers =========="
            docker ps -a || true

            echo ""
            echo "========== Docker Images =========="
            docker images || true

            echo ""
            echo "========== Container Logs =========="
            docker logs ${CONTAINER_NAME} || true
            '''
        }

        always {
            cleanWs()
            echo "Pipeline execution completed."
        }
    }
}
