pipeline {
    agent any

    parameters {
        string(
            name: 'BRANCH_NAME',
            defaultValue: 'main',
            description: 'Name of the branch you want to build'
        )
    }

    environment {
        acr_registry = 'krmygecr.azurecr.io'
        repository = 'nginx'
        deploy_env = 'poc'
        argocdFile = 'admin'
    }

    stages {
        stage('Clone repository') {
            steps {
                checkout(
                    scm: [$class: 'GitSCM', branches: [[name: "${params.BRANCH_NAME}"]], 
                        userRemoteConfigs: [[url: 'git@github.com:sonulodha/krmyg-app.git']]
                    ]
                )
            }
        }

        stage('Build Container Image') {
            steps {
                script {
                    env.git_commit_sha = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    def imageTag = "${acr_registry}/${repository}:${env.git_commit_sha}"
                    sh "docker build -t ${imageTag} ."
                }
            }
        }

        stage('Push Container Image to ACR') {
            steps {
                script {
                    def imageTag = "${acr_registry}/${repository}:${env.git_commit_sha}"
                    sh "docker push ${imageTag}"
                }
            }
        }

        stage('Clone GitOps repository') {
            steps {
                sh "git clone git@github.com:sonulodha/GitOps.git"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                        cd GitOps
                        sed -i "s/.*tag:.*/  tag: ${env.git_commit_sha}/g" valuestore/${deploy_env}/${argocdFile}.yaml
                        git config --global user.name "Argocd"
                        git config --global user.email "sonulodha@yahoo.com"
                        git add valuestore/${deploy_env}/${argocdFile}.yaml || true
                        git commit -m "Done by Jenkins job ${env.git_commit_sha}" || true
                        git pull 
                        git push origin main || true
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
