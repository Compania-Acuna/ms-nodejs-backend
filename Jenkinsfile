pipeline {
    agent {
        docker {
            image 'devops-agent:latest'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        APELLIDO = 'jacuna'
        ACR_NAME = 'acrjacuna'
        ACR_LOGIN_SERVER = 'acrjacuna.azurecr.io'
        IMAGE_NAME = 'my-nodejs-app-jacuna'
        RESOURCE_GROUP = 'rg-cicd-aks-jacuna'
        AKS_NAME = 'aks-dev-eastus'
    }

    stages {
        stage('[CI] Instalar dependencias de app') {
            steps { sh 'npm install' }
        }
        stage('[CI] Ejecutar pruebas unitarias') {
            steps { sh 'npm run test:unit' }
        }
        stage('[CI] Ejecutar pruebas de integración') {
            steps { sh 'npm run test:integration' }
        }
        stage('[CI] Azure Login') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-clientId', variable: 'AZ_CLIENT_ID'),
                    string(credentialsId: 'azure-clientSecret', variable: 'AZ_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenantId', variable: 'AZ_TENANT_ID'),
                    string(credentialsId: 'azure-subscriptionId', variable: 'AZ_SUBSCRIPTION_ID')
                ]) {
                    sh '''
                        az login --service-principal --username="$AZ_CLIENT_ID" --password="$AZ_CLIENT_SECRET" --tenant="$AZ_TENANT_ID"
                        az account set --subscription "$AZ_SUBSCRIPTION_ID"
                    '''
                }
            }
        }
        stage('[CI] AKS Credentials') {
            steps { sh 'az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing' }
        }
        stage('[CI] Generar ID corto del commit') {
            steps {
                script {
                    env.IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            }
        }
        stage('[CI] Build and Push Docker Image') {
            steps {
                sh '''
                    az acr login --name $ACR_NAME
                    docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
                    docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
        stage('[CD-DEV] Deploy a AKS') {
            steps {
                sh '''
                    ENV=dev API_PROVIDER_URL=https://dev.api.com envsubst < k8s.yml > k8s-dev.yml
                    kubectl apply -f k8s-dev.yml
                '''
            }
        }
        stage('[CD-DEV] Imprimir IP del servicio') {
            steps { sh 'kubectl get service my-nodejs-service-${APELLIDO}-dev' }
        }
        stage('Aprobación QA') {
            steps { input message: '¿Aprobar despliegue a QA?', ok: 'Sí, continuar' }
        }
        stage('[CD-QA] Deploy a AKS') {
            steps {
                sh '''
                    ENV=qa API_PROVIDER_URL=https://qa.api.com envsubst < k8s.yml > k8s-qa.yml
                    kubectl apply -f k8s-qa.yml
                '''
            }
        }
        stage('[CD-QA] Imprimir IP del servicio') {
            steps { sh 'kubectl get service my-nodejs-service-${APELLIDO}-qa' }
        }
        stage('Aprobación PRD') {
            steps { input message: '¿Aprobar despliegue a PRD?', ok: 'Sí, continuar' }
        }
        stage('[CD-PRD] Deploy a AKS') {
            steps {
                sh '''
                    ENV=prd API_PROVIDER_URL=https://api.com envsubst < k8s.yml > k8s-prd.yml
                    kubectl apply -f k8s-prd.yml
                '''
            }
        }
        stage('[CD-PRD] Imprimir IP del servicio') {
            steps { sh 'kubectl get service my-nodejs-service-${APELLIDO}-prd' }
        }
    }
}
