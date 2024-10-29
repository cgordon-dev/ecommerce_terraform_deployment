pipeline {
  agent any
  stages {
    stage('Init') {  // Moved to the top for better flow
      steps {
        dir('Terraform') {
          sh 'terraform init' 
        }
      }
    }
    stage('Build') {
      steps {
        dir('backend') {
          sh '''#!/bin/bash
          sudo add-apt-repository ppa:deadsnakes/ppa
          sudo apt install python3.9 python3.9-venv python3.9-dev git -y
          python3.9 -m venv venv
          source venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements.txt
          '''
        }
      }
    }
    stage('Test') {
      steps {
        dir('backend') {
          sh '''#!/bin/bash
          if [ -d "venv" ]; then
            source venv/bin/activate
            export PYTHONPATH=$(pwd)
            pip install pytest-django
            python manage.py makemigrations
            python manage.py migrate
            pytest account/tests/*.py --verbose --junit-xml test-reports/results.xml
          else
            echo "Virtual environment not found!"
            exit 1
          fi
          ''' 
        }
      }
    }
    stage('Plan') {
      steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'), 
                          string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                          string(credentialsId: 'RDS_PASSWORD', variable: 'db_password')]) {
          dir('Terraform') {
            sh 'terraform plan -out plan.tfplan -var="aws_access_key=${AWS_ACCESS_KEY_ID}" -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var="db_password=${db_password}" -var="region=<region_name>"' 
          }
        }
      }     
    }
    stage('Apply') {
      steps {
        dir('Terraform') {
          sh 'terraform apply -auto-approve plan.tfplan' 
        }
      }  
    }       
  }
}
