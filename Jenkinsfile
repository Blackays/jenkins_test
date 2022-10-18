#!/usr/bin/env groovy

pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }
        stage('build app') {
            steps {
               script {
                   echo "building the application..."
                   sh 'mvn clean package'
               }
            }
        }
        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t blackays/${IMAGE_NAME} ."
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push blackays/${IMAGE_NAME}"
                    }
                }
            }
        }
        stage('provision server') {
            environment {
                DIGITALOCEAN_ACCESS_TOKEN = credentials('DIGITALOCEAN_ACCESS_TOKEN')
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        DROPLET_PUBLIC_IP= sh (
                            script: "terraform output droplet_ipv4",
                            returnStdout: true
                            ).trim()
                    }
                }
            }
        }
        stage('deploy') {
            steps {
                script {
                    echo "waiting for droplet to initialize"
                    //sleep(time: 90,unit: "SECONDS")

                    echo "deploying the docker image to Droplet..."
                    echo "${DROPLET_PUBLIC_IP}"

                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    def droplet = "root@${DROPLET_PUBLIC_IP}"

                    sshagent(['droplet-server-key']) {
                        sh "ls"
                        sh "ls /"
                        sh "pwd"
                        sh "ls /home/"
                        //sh "ls /home/user/"
                        //sh "touch /home/user/lol.txt"

                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${droplet}:/home/user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${droplet}:/home/user"
                        sh "ssh -o StrictHostKeyChecking=no ${droplet} ${shellCmd}"
                    }
                }
            }
        } 
        stage('commit version update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh 'git config user.email "jenkins@example.com"'
                        sh 'git config user.name "Jenkins"'
                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/Blackays/jenkins_test.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh 'git push origin HEAD:main'
                    }
                }
            }
        }
    }
}
