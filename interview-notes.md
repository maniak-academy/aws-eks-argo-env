Application authenticating to my backend database
- in this current configuration we are using github actions secrets to store the credentials username/password

- Move this towards AWS Secrets or Thirdpary secets tool like vault

* show git hub repo https://github.com/maniak-academy/simple-task-app 

AWS Config 

AWS Config provides an inventroy of our aws resorice and history of configuration change to these resources
- we can create rules that will give us compliance and analasys

EC2 SSH Rule

sg-0a1ecf6a691329dc7 - 22 allowed on port 22
- it does not meet the complaince and we can remove 22 or restrict access to it

EC2 IAM Policy
We can see that we have EC2FullAccess policy with noncomplaint because we created a database_role that gives us EC2 full permission
- We would want to go ahead and remove full permission and specify the specific 


AWS Config
AWS Secrets we are storing database credentials in aws secrets and they are not being rotate .. the complaince is failing here.


EKS Pack
- Our EKS cluster is publically accessible also which is not compliant


S3 bucket
This bucket will be holding the database backups and permissions. 
s3://eks-wiz-mongodb-bucket/backups/

aws s3 ls s3://eks-wiz-mongodb-bucket

Database backup
We have a cronjob that gets started as the mongodb gets booted 
- To secure this i would assing a policy for it to be able to upload to s3 bucket
