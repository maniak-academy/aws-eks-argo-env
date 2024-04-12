# MongoDB

Step 1: Build S3 bucket for mongodb

```bash
aws s3api create-bucket --bucket eks-wiz-mongodb-bucket --region us-east-1 
```
Step 2: Set Public Read Access

```bash
aws s3api put-bucket-policy --bucket eks-wiz-mongodb-bucket --policy file://s3policy.json
```

Step 3: Ensure the Bucket has Public Access Configurations Set

```bash
aws s3api put-public-access-block --bucket eks-wiz-mongodb-bucket --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

Step 4: Verify Bucket Policy

```bash
aws s3api get-bucket-policy --bucket eks-wiz-mongodb-bucket
```