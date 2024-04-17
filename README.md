# poc-eks-argocd

## Env Setup
![diagram](diagram.png)


## Setup the initial-build
1. This builds the Terraform S3 bucket to store our state
2. Clone this repo into your github 
3. You will need to edit the provider.tf with your s3 bucket info
4. Edit the variables.tf var.projects with your own name
5. Note argocd is using fqdn so you need to edit the argocd.tf with your domain name in aws.
5. Edit the Github secrets to include [AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,MONGO_ADMIN_PASSWORD, MONGO_ADMIN_USER]
6. Rerun the terraform workflow in github actions
7. Once the environment is deployed you need to log into the cluster and install argocd ```aws eks --region us-east-1 update-kubeconfig --name eks-maniak```
8. cd into the argocd folder ```kubectl apply -f```
9. get the argocd creds ```kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo```
10. Argo cd is using fdqn, 

### If you are using argo cli you can change the creds this way. Or use the gui

4. argocd login <ARGOCD_SERVER> --username admin --password <PASSWORD>
5. argocd account update-password



### Note

This repository creates a VPC with private and public subnets and nat gateway with connection to internet gateway.

The EKS Version 1.29 is created on the created VPC , there is an option to switch between public and private(only within the vpc).

The Additional Supporting components Cluster AutoScaler,AWS Loadbalancer Controller and External DNS are also created by the repo as helm charts.

ArgoCD is created . there is an option to set the domain in the argocd.tf values this has to be set to the proper fqdn for argocd to function properly externally. additionally argocd needs an ingress to be defined to the same fqdn (host).

The terraform cleanly creates and destroys. If destroy fails for some reason, you need to just rerun destroy because eks cluster times out on deletion. There is an argocd-ingress.yaml under terraform folder for creating the argocd ingress(loadbalancer). It should be integrated in github actions. the manifest argocd-ingress.yaml should be applied via kubectl apply -f argocd-ingress.yaml after doing "aws eks update-kubeconfig --name --name us-east-2 "just after the terraform apply. also you need to kubectl delete the ingress before doing the terraform destroy . these can be done in github actions ci/cd
