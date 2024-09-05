pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "tonytran1997/todo-app:${env.BRANCH_NAME}-${env.BUILD_ID}"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build(env.DOCKER_IMAGE)
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        dockerImage.push("${env.BRANCH_NAME}-${env.BUILD_ID}")
                        dockerImage.push("staging-latest")
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([kubernetesCredential('k8s-staging-jenkins-sa-token')]) {
                        checkout scm  // Lấy mã nguồn từ Git để có deployment.yaml
                        // Áp dụng file deployment.yaml
                        sh "kubectl apply -f deployment.yaml --namespace=staging"
                        // Cập nhật image mới nhất trong deployment
                        sh "kubectl set image deployment/todo-app todo-app=${env.DOCKER_IMAGE} --namespace=staging"
                    }
                }
            }
        }
    }
}
