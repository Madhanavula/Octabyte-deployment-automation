pipeline {

    agent any

    environment {
        DOCKER_IMAGE = "kubemadhan/hello-devops"
        IMAGE_TAG = "${BUILD_NUMBER}"
        APP_SERVER = "13.233.152.117"
    }
    

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m pip install --user -r requirements-dev.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    pytest -v tests/test_unit.py
                '''
            }
        }

        stage('Integration Tests') {
            steps {
                sh '''
                    pytest -v tests/test_integration.py
                '''
            }
        }

        stage('Dependency Vulnerability Scan') {
            steps {
                sh '''
                    pip-audit -r requirements.txt
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                    -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                    -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Application Server') {

            steps {

                sshagent(['ec2-ssh']) {

                    sh '''
                        ssh -o StrictHostKeyChecking=no \
                            ubuntu@${APP_SERVER} \
                            "docker pull ${DOCKER_IMAGE}:${IMAGE_TAG} && \
                             docker stop hello-devops || true && \
                             docker rm hello-devops || true && \
                             docker run -d \
                             --name hello-devops \
                             -p 80:5000 \
                             ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    '''
                }
            }
        }

        stage('Smoke Test') {

            steps {

                sh '''
                    sleep 10

                    curl --fail \
                        http://${APP_SERVER}/health
                '''
            }
        }
    }

    post {

        success {

            slackSend(
                channel: '#devops-alerts',
                message: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }

        failure {

            slackSend(
                channel: '#devops-alerts',
                message: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }

        always {

            echo "Build ${env.BUILD_NUMBER} completed."
        }
    }
}
