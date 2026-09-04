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
                docker build -t hello-devops:latest .
                docker tag hello-devops:latest kubemadhan/hello-devops:latest
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
                    docker push kubemadhan/hello-devops:latest
                    docker logout
                    '''
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                docker pull kubemadhan/hello-devops:latest

                docker stop hello-devops || true
                docker rm hello-devops || true

                docker run -d \
                --name hello-devops \
                -p 8083:8080 \
                kubemadhan/hello-devops:latest
                '''
            }
        }
        
    }
}
