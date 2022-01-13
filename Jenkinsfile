pipeline {

    environment {
        IMAGE_NAME = "ic-webapp"
        IMAGE_TAG = "1.0"
        USERNAME = "itirenegad"
        CONTAINER_NAME = "test-ic-webapp"
        EC2_ADMIN_HOST = "52.91.186.73"
        EC2_ODOO_HOST = "3.89.74.212"
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
       stage('Deploy app on EC2-cloud preprod') {
            agent any
            steps{
                withCredentials([sshUserPrivateKey(credentialsId: "	SSHCredentials", keyFileVariable: 'keyfile', usernameVariable: 'NUSER')]) {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        script{ 

                            sh'''
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${EC2_ADMIN_HOST} docker run --name $CONTAINER_NAME -d -e "ODOO_URL=http://${EC2_ODOO_HOST}:8069" -e "PGADMIN_URL=https://ipv4.monip.eu/" -p 80:80 $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                            '''
                        }
                    }
                }
            }
       }
    }
}
