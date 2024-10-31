

Kura Labs Cohort 5 - Deployment Workload 5

Purpose

Workload 5 focuses on Infrastructure as Code (IaC) to create a robust, scalable, and secure deployment environment. In Workload 4, I improved security and resource distribution for the infrastructure. In Workload 5, my goal is to further optimize the pipeline and automate the deployment process by leveraging tools like Jenkins, Terraform, and AWS. This workload will ultimately serve as a foundation for deploying applications efficiently and effectively.

Steps

Each step in this workload was carefully documented, detailing both the actions taken and why each step is essential.

Understanding the Manual Deployment Process

	1.	Clone the Repository: I began by cloning the repository to my GitHub account. This allowed me to maintain version control and track changes throughout the project.
	2.	Create EC2 Instances: I set up two t3.micro EC2 instances, one for the Frontend (React) and the other for the Backend (Django). Opening necessary ports (22 for SSH, 3000 for Frontend, 8000 for Backend) ensured proper access to these resources.
	3.	Backend EC2 Setup: On the Backend EC2 instance, I installed Python 3.9 and created a virtual environment. I then installed the required dependencies listed in the requirements.txt file, which are essential for the Django application.
	4.	Update settings.py: I modified settings.py to include the Backend EC2’s private IP in the ALLOWED_HOSTS setting. This step ensures the backend server only allows connections from approved hosts, enhancing security.
	5.	Start Django Server: I launched the Django server on the Backend EC2 instance with python manage.py runserver 0.0.0.0:8000, making it accessible over the network.
	6.	Frontend EC2 Setup: On the Frontend EC2 instance, I installed Node.js and npm, necessary for running the React application.
	7.	Update package.json: I modified the package.json proxy field to direct traffic to the Backend EC2’s private IP. This step allowed the frontend to connect to the backend properly.
	8.	Install Frontend Dependencies: Using npm i, I installed all the dependencies required by the frontend application.
	9.	Start React Application: Setting the Node.js options to --openssl-legacy-provider, I started the React app with npm start. This enabled me to access the application through the frontend’s public IP and verify its functionality by viewing the products fetched from the backend.
	10.	Terminate EC2 Instances: After validating the application, I terminated the EC2 instances. This was done to avoid running unnecessary resources, adhering to best practices.

Automating with IaC and CI/CD Pipeline

	1.	Create Jenkins_Terraform EC2: I deployed a t3.medium EC2 instance dedicated to Jenkins and Terraform to manage the CI/CD pipeline and infrastructure provisioning.
	2.	Define Terraform Configuration: I created the necessary Terraform files to automate the following infrastructure:
	•	Custom VPC in us-east-1
	•	Subnets (public and private) across two Availability Zones
	•	EC2 Instances for frontend and backend in both Availability Zones
	•	Load Balancer for directing traffic to public subnets
	•	RDS Database for persistent data storage
	3.	RDS Database Configuration: Using the provided resource blocks, I added an RDS PostgreSQL instance in Terraform, along with necessary security groups and subnet groups to secure database access.
	4.	Jenkinsfile Stages: I edited the Jenkinsfile to include stages for building, testing, and deploying:
	•	Build: Compiles the application
	•	Test: Runs automated tests for validation
	•	Init, Plan, Apply: Executes Terraform commands to provision infrastructure and deploy the application
	5.	Frontend and Backend Setup Scripts: I created user data scripts for both frontend and backend instances, automating the setup of each server and ensuring the applications launch upon instance creation.
	6.	Automate Host IP Configuration: Using sed, I replaced IP placeholders in settings.py and package.json to connect the frontend and backend automatically, improving efficiency by avoiding manual intervention.
	7.	Database Migration: I created migration scripts to initialize the RDS database, set up tables, and load data from an SQLite file to the PostgreSQL database, enabling persistent data storage in a centralized location.
	8.	Jenkins Credentials Management: For security, I used Jenkins Secret Manager to store AWS credentials, ensuring that sensitive data like access keys are never exposed in the code.
	9.	Run Jenkins Pipeline: I executed the Jenkins pipeline to deploy the application, using the pipeline to automate every aspect of infrastructure provisioning and application deployment.
	10.	Monitoring EC2: I deployed a monitoring instance in the default VPC to monitor resource utilization across all servers, ensuring operational efficiency.

System Design Diagram

For a visual representation, I’ve created a system design diagram in Draw.io, saved as Diagram.jpg in the root directory. It illustrates the VPC layout, subnets, EC2 instances, load balancer, and RDS database, showing how the components are interconnected.

Issues and Troubleshooting

	1.	EC2 Connection Issues: Initially faced SSH connectivity problems due to misconfigured security groups. Adjusting the inbound rules resolved this.
	2.	Database Connection Errors: Encountered timeout errors when connecting to the RDS instance. This was due to missing VPC security group configurations, which I updated to allow access on port 5432.
	3.	Pipeline Failures: The Jenkins pipeline failed during the initial run due to missing dependencies. I modified the Jenkinsfile and added necessary commands to install dependencies, which solved the issue.

Optimization

	•	Automation of IP Configuration: Although partially automated, fully automating IP configurations between frontend and backend would enhance efficiency.
	•	Load Balancing Strategy: Implementing an auto-scaling strategy with the load balancer would provide better resource management.
	•	Monitoring and Alerts: Integrating CloudWatch for real-time monitoring and automated alerts could improve response times to resource issues.

Business Intelligence

	1.	Schema Diagram: I’ve included a diagram of the database schema relationships in schema.jpg using Draw.io.
	2.	SQL Queries and Results:
	•	Data Count:

SELECT COUNT(*) FROM auth_user;
SELECT COUNT(*) FROM product;
SELECT COUNT(*) FROM account_ordermodel;


	•	Top and Bottom 5 States by Product Orders:

SELECT state, COUNT(*) as order_count FROM account_ordermodel GROUP BY state ORDER BY order_count DESC LIMIT 5;
SELECT state, COUNT(*) as order_count FROM account_ordermodel GROUP BY state ORDER BY order_count ASC LIMIT 5;


	•	Top 3 Most Sold Products:

SELECT product_id, COUNT(*) as sale_count FROM account_ordermodel GROUP BY product_id ORDER BY sale_count DESC LIMIT 3;



Conclusion

In this workload, I enhanced my understanding of IaC, automated deployment pipelines, and the importance of CI/CD in managing large-scale infrastructure. By combining manual setup, Terraform, Jenkins, and AWS, I’ve created a robust, secure environment for deploying applications. The skills learned in workload 5 will enable me to deploy applications more efficiently and adapt to various infrastructure demands in future projects.
