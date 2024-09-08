pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "tonytran1997/todo-app:${env.BRANCH_NAME}-${env.BUILD_ID}"  // Image được xây dựng với tag branch-BUILD_ID
        LATEST_IMAGE = "tonytran1997/todo-app:latest"  // Image mới nhất cho môi trường production
        K8S_API_URL = 'https://103.173.66.104:6443'
        KUBECONFIG_CREDENTIALS_ID = 'k8s-production-jenkins-sa-token'
        NAMESPACE = 'production'
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
                        dockerImage.push("latest")
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
        stage('Verify Deployment YAML Exists') {
            steps {
                script {
                    sh "ls -la"
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([string(credentialsId: "${KUBECONFIG_CREDENTIALS_ID}", variable: 'KUBE_TOKEN')]) {

                        checkout scm

                        sh """
                            kubectl config set-credentials jenkins-user --token=${KUBE_TOKEN}
                            kubectl config set-cluster jenkins-cluster --server=${K8S_API_URL} --insecure-skip-tls-verify=true
                            kubectl config set-context jenkins-context --cluster=jenkins-cluster --user=jenkins-user --namespace=${NAMESPACE}
                            kubectl config use-context jenkins-context
                        """

                        sh "kubectl apply -f deployment.yaml --namespace=${NAMESPACE}"

                        sh "kubectl set image deployment/todo-app todo-app=${env.DOCKER_IMAGE} --namespace=${NAMESPACE}"

                        // sh "kubectl rollout restart deployment/todo-app --namespace=${NAMESPACE}"

                        sh "kubectl rollout status deployment/todo-app --namespace=${NAMESPACE}"
                    }
                }
            }
        }
    }
}
