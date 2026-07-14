pipeline {
    agent any

    tools {
        jdk 'JDK21'
        maven 'Maven3'
    }

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
                echo "========================================"
                echo " Jenkins Environment Check"
                echo "========================================"

                echo ""
                echo "JAVA_HOME=$JAVA_HOME"

                echo ""
                echo "PATH=$PATH"

                echo ""
                echo "which java"
                which java

                echo ""
                echo "which javac"
                which javac

                echo ""
                echo "which mvn"
                which mvn

                echo ""
                echo "Java Version"
                java -version

                echo ""
                echo "Javac Version"
                javac -version

                echo ""
                echo "Maven Version"
                mvn -version
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
                echo "Generated files"
                ls -lh target/

                echo ""
                echo "Dockerfile"
                cat Dockerfile
                '''
            }
        }
        
        stage('Upload Artifact to S3') {
            steps {
                sh '''
                aws s3 cp target/jenkins-dockerized-demo-1.0.0.jar \
                s3://jenkins-artifacts-2026-923093694371-ap-south-1-an/
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

                for i in $(seq 1 12)
                do
                    STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:${HOST_PORT} || true)

                    if [ "$STATUS" = "200" ]; then
                        echo "Application is UP"
                        exit 0
                    fi

                    echo "Attempt $i : Waiting..."
                    sleep 5
                done

                echo "Application failed Health Check"

                docker logs ${CONTAINER_NAME} || true

                exit 1
                '''
            }
        }
    }

    post {

        success {
            echo "Build Successful"
        }

        failure {
            echo "Pipeline Failed"

            sh '''
            echo "========== JAVA =========="
            java -version || true

            echo ""
            echo "========== MAVEN =========="
            mvn -version || true

            echo ""
            echo "========== DOCKER CONTAINERS =========="
            docker ps -a || true

            echo ""
            echo "========== DOCKER IMAGES =========="
            docker images || true

            echo ""
            echo "========== CONTAINER LOGS =========="
            docker logs ${CONTAINER_NAME} || true
            '''
        }

        always {
            cleanWs()
            echo "Pipeline execution completed."
        }
    }
}
