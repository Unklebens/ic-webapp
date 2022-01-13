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

       stage ('run ansible playbook') {
           agent any
           steps {
               script{
                   sh '''
                       rm -rf ./deploy_ic_webapp
                       git clone https://github.com/Unklebens/deploy_ic_webapp.git
                       ansible-galaxy install -r ./deploy_ic_webapp/role/requirements.yml --force
                       ansible-playbook -i hosts.yml ic-webapp.yml
                   '''
               }
           }
       }

    }
}
