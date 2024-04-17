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
We can see that we have  EC2FullAccess policy with noncomplaint