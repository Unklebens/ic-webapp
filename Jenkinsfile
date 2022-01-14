pipeline {

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        IMAGE_NAME = "ic-webapp"
        IMAGE_TAG = "1.0"
        USERNAME = "itirenegad"
        CONTAINER_NAME = "test-ic-webapp"
    }

    agent none

    stages{
        
       stage ('Build Image'){
           agent any
           steps {
               script{
                   sh 'docker build -t $USERNAME/$IMAGE_NAME:$IMAGE_TAG .'
               }
           }
       }

       stage ('Run test container') {
           agent any
           steps {
               script{
                   sh '''
                       docker stop $CONTAINER_NAME || true
                       docker rm $CONTAINER_NAME || true
                       docker run --name $CONTAINER_NAME -d -e "ODOO_URL=http://URL1.com" -e "PGADMIN_URL=http://URL2.com" -p 8888:80 $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                       sleep 5
                   '''
               }
           }
       }

       stage ('Test application') {
           agent any
           steps {
               script{
                   sh '''
                       curl http://localhost:8888 | grep -iq "Intranet"
                   '''
               }
           }
       }

       stage ('clean env and save artifact') {
           agent any
           environment{
               PASSWORD = credentials('DockerHubCredentials')
           }
           steps {
               script{
                   sh '''
                       docker login -u $USERNAME -p $PASSWORD
                       docker push $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                       # docker stop $CONTAINER_NAME || true
                       # docker rm $CONTAINER_NAME || true
                       # docker rmi $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                   '''
               }
           }
       }

       stage ('Git Clone terraform script files') {
           agent any
           steps {
               script{
                   sh '''
                       rm -rf Terraform_Projet_Final || true
                       git clone https://github.com/Unklebens/Terraform_Projet_Final.git

                   '''
               }
           }
       }

       stage ('Build test infrastructure') {
           agent any
           steps {
               script{
                   sh '''
                       cd Terraform_Projet_Final/app
                       terraform init
                       terraform apply --auto-approve
                       sleep 45
                       
                   '''
               }
           }
       }


       stage('Ansible playbook Odoo') {
            agent any
            environment {
                IPODOO = "${sh(script:'cat hostodoo.ini', returnStdout: true).trim()}"
            }
            steps{
                withCredentials([sshUserPrivateKey(credentialsId: "SSHCredentials", keyFileVariable: 'keyfile', usernameVariable: 'NUSER')]) {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        script{ 

                            sh'''
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPODOO} sudo apt update -y
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPODOO} sudo apt install ansible git -y
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPODOO} rm -rf deploy_odoo || true
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPODOO} git clone https://github.com/Unklebens/deploy_odoo.git
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPODOO} ansible-galaxy install -r ./deploy_odoo/role/requirements.yml --force
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPODOO} ansible-playbook ./deploy_odoo/odoo.yml
                            '''
                        }
                    }
                }
            }
        }


       stage('Ansible playbook vitrine+PGadmin') {
            agent any
            environment {
                IPADMIN = "${sh(script:'cat hostadmin.ini', returnStdout: true).trim()}"
                IPPUBLICODOO = "${sh(script:'cat hostodoopublic.ini', returnStdout: true).trim()}"
                IPPUBLICADMIN = "${sh(script:'cat hostadminpublic.ini', returnStdout: true).trim()}"
            }
            steps{
                withCredentials([sshUserPrivateKey(credentialsId: "SSHCredentials", keyFileVariable: 'keyfile', usernameVariable: 'NUSER')]) {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        script{ 

                            sh'''
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} sudo apt update -y
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} sudo apt install ansible git -y
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} rm -rf deploy_ic_webapp || true
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} git clone https://github.com/Unklebens/deploy_ic_webapp.git
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} ansible-galaxy install -r ./deploy_ic_webapp/role/requirements.yml --force
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} ansible-playbook ./deploy_ic_webapp/ic-webapp.yml -e odoo_url=${IPPUBLICODOO} -e pgadmin_url=${IPPUBLICADMIN}

                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} rm -rf deploy_pgadmin4 || true
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} git clone https://github.com/Unklebens/deploy_pgadmin4.git
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} ansible-galaxy install -r ./deploy_pgadmin4/role/requirements.yml --force
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${IPADMIN} ansible-playbook ./deploy_pgadmin4/pgadmin4.yml
                            '''
                        }
                    }
                }
            }
        }

       stage ('destroy test infra') {
           agent any
           steps {
               script{
                   timeout(time: 30, unit: "MINUTES") {
                                input message: 'Do you want to destroy this test infra?', ok: 'Yes'
                            }
                   sh '''
                       cd Terraform_Projet_Final/app
                       terraform destroy --auto-approve
                       
                   '''
               }
           }
       }
    }
}
