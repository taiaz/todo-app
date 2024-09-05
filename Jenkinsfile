pipeline {
    agent any
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Xây dựng Docker image với tag là sự kết hợp của tên nhánh và BUILD_ID
                    dockerImage = docker.build("tonytran1997/todo-app:${env.BRANCH_NAME}-${env.BUILD_ID}")
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Đăng nhập vào Docker Hub
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        // Push image với tag mới và tag là latest
                        dockerImage.push("latest")
                        dockerImage.push("${env.BRANCH_NAME}-${env.BUILD_ID}")
                    }
                }
            }
        }
    }
}
