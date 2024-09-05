pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "tonytran1997/todo-app:${env.BRANCH_NAME}-${env.BUILD_ID}"
        K8S_API_URL = 'https://103.173.66.104:6443'
        KUBECONFIG_CREDENTIALS_ID = 'k8s-staging-jenkins-sa-token'
        NAMESPACE = 'staging'
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
        stage('Check Kubernetes Connection') {
            steps {
                script {
                    withCredentials([string(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBE_TOKEN')]) {
                        sh "curl --insecure --header 'Authorization: Bearer ${KUBE_TOKEN}' ${K8S_API_URL}/api/v1/nodes"
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([string(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBE_TOKEN')]) {
                        // Checkout code từ GitHub để lấy deployment.yaml
                        checkout scm

                        // Thiết lập context cho kubectl bằng token
                        sh """
                            kubectl config set-credentials jenkins-user --token=${KUBE_TOKEN}
                            kubectl config set-context jenkins-context --cluster=kubernetes --user=jenkins-user --namespace=${NAMESPACE}
                            kubectl config use-context jenkins-context
                        """
                        
                        // Triển khai file deployment.yaml lên Kubernetes
                        sh "kubectl apply -f deployment.yaml --namespace=${NAMESPACE}"

                        // Cập nhật image mới nhất trong Kubernetes deployment
                        sh "kubectl set image deployment/todo-app todo-app=${env.DOCKER_IMAGE} --namespace=${NAMESPACE}"
                    }
                }
            }
        }
    }
}
