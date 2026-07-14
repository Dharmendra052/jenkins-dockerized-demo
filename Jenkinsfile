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
        APP_NAME = "jenkins-dockerized-demo"
        APP_PORT = "8082"
        S3_BUCKET = "jenkins-artifacts-2026-923093694371-ap-south-1-an"
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
                echo "Jenkins Environment Check"
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
                echo "Generated Files"
                ls -lh target/

                echo ""
                echo "Dockerfile"
                cat Dockerfile || true
                '''
            }
        }

        stage('Upload Artifact to S3') {
            steps {
                sh '''
                aws s3 cp target/jenkins-dockerized-demo-1.0.0.jar \
                s3://${S3_BUCKET}/
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                echo "Stopping existing application..."
                pkill -f "${APP_NAME}" || true

                echo "Starting new application..."

                nohup java -jar \
                /var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_NUMBER}/archive/target/jenkins-dockerized-demo-1.0.0.jar \
                --server.port=${APP_PORT} \
                > /var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_NUMBER}/archive/target/app.log 2>&1 &

                sleep 10
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                echo "Waiting for application to start..."

                for i in $(seq 1 12)
                do
                    STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:${APP_PORT} || true)

                    if [ "$STATUS" = "200" ]; then
                        echo "Application is UP"
                        exit 0
                    fi

                    echo "Attempt $i : Waiting..."
                    sleep 5
                done

                echo ""
                echo "Application failed Health Check"

                echo ""
                echo "Application Log"
                cat /var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_NUMBER}/archive/target/app.log || true

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
            echo "========== RUNNING JAVA PROCESS =========="
            ps -ef | grep java || true

            echo ""
            echo "========== APPLICATION LOG =========="
            cat /var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_NUMBER}/archive/target/app.log || true
            '''
        }

        always {
            echo "Pipeline Execution Completed"
        }
    }
}
