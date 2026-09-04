pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Madhanavula/Octabyte-deployment-automation.git'
            }
        }

        stage('Verify Tools') {
            steps {
                sh 'mvn -version'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t octabyte:latest .
                docker tag octabyte:latest kubemadhan/octabyte:latest
                docker images
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push kubemadhan/octabye:latest
                    docker logout
                    '''
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                docker pull kubemadhan/octabye:latest

                docker stop octabyte || true
                docker rm octabyte || true

                docker run -d \
                --name octabyte \
                -p 8083:8080 \
                kubemadhan/octabye:latest
                '''
            }
        }
        
    }
}
