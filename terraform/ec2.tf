resource "aws_iam_instance_profile" "database_instance_profile" {
  name = "database_instance_profile"
  role = aws_iam_role.database_role.name
}

resource "aws_secretsmanager_secret" "mongodb_secret" {
  name        = "admin_mongodb"
  description = "MongoDB admin credentials"
}

resource "aws_secretsmanager_secret_version" "mongodb_secret_version" {
  secret_id     = aws_secretsmanager_secret.mongodb_secret.id
  secret_string = jsonencode({
    username = var.mongo_admin_user
    password = var.mongo_admin_password
  })
}

resource "aws_iam_role" "database_role" {
  name = "database_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_full_access" {
  name        = "EC2FullAccess"
  description = "Grants full access to EC2 resources and Secrets Manager get operation"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ec2:*",
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_full_access_attachment" {
  role       = aws_iam_role.database_role.name
  policy_arn = aws_iam_policy.ec2_full_access.arn
}


resource "aws_instance" "mongodb_instance" {
  ami                         = "ami-080e1f13689e07408"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = "us-east-1key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.MongoDB_sg.id]

  iam_instance_profile        = aws_iam_instance_profile.database_instance_profile.name

  tags = {
    Name = "MongoDBInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y gnupg curl awscli unzip

              # Fetch MongoDB admin credentials from Secrets Manager
              CREDENTIALS_JSON=$(aws secretsmanager get-secret-value --secret-id "${aws_secretsmanager_secret.mongodb_secret.id}" --query 'SecretString' --output text)
              ADMIN_USER=$(echo $CREDENTIALS_JSON | jq -r .username)
              ADMIN_PASSWORD=$(echo $CREDENTIALS_JSON | jq -r .password)

              # MongoDB installation
              curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
              sudo apt-get update -y
              sudo apt-get install -y mongodb-org
              sudo systemctl start mongod
              sudo systemctl enable mongod
              mkdir /home/ubuntu/mongo

              # MongoDB configuration for user creation and enabling auth
              while ! mongosh --eval "db.adminCommand('ping')"; do sleep 1; done
              mongosh admin --eval "db.createUser({user: '${var.mongo_admin_user}', pwd: '${var.mongo_admin_password}', roles: [{ role: 'userAdminAnyDatabase', db: 'admin' }, { role: 'readWriteAnyDatabase', db: 'admin' }]})"
              echo 'security:
                authorization: enabled' | sudo tee -a /etc/mongod.conf
              sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
              sudo systemctl restart mongod

              # Get the Mongdb Copy Script
              curl https://eks-wiz-mongodb-bucket.s3.amazonaws.com/mongodb_backup.sh -o /home/ubuntu/mongodb_backup.sh
              chmod +x /home/ubuntu/mongodb_backup.sh 
              sudo ./home/ubuntu/mongodb_backup.sh ${var.mongo_admin_user} ${var.mongo_admin_password}
              
              # Configure cron job for MongoDB backup
              (crontab -l 2>/dev/null; echo "*/30 * * * * sudo /home/ubuntu/mongodb_backup.sh ${var.mongo_admin_user} ${var.mongo_admin_password} >> /home/ubuntu/mongodb_backup.log 2>&1 && echo 'MongoDB backup completed successfully at \$(date +\"%Y-%m-%d %H:%M:%S\")' >> /home/ubuntu/mongodb_backup.log || echo 'MongoDB backup failed at \$(date +\"%Y-%m-%d %H:%M:%S\")' >> /home/ubuntu/mongodb_backup.log") | crontab -
            EOF
}



resource "aws_route53_zone" "internal_zone" {
  name = "internal.maniak.academy"
  vpc {
    vpc_id     = aws_vpc.myvpc.id
    vpc_region = "us-east-1"
  }
  tags = {
    Name = "Internal Zone"
  }
}

resource "aws_route53_record" "mongodb_record" {
  zone_id = aws_route53_zone.internal_zone.zone_id
  name    = "mongodb.internal.maniak.academy"
  type    = "A"
  ttl     = "300"

  records = [aws_instance.mongodb_instance.private_ip]
}

resource "aws_security_group" "MongoDB_sg" {
  name        = "MongoDB_sg"
  description = "Allow inbound traffic on port 80 and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id # Replace this with your VPC ID if needed

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows traffic from any IP address. Narrow this down as necessary for your use case.
  }
  ingress {
    description = "db"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [var.vpc_cidr] # Allows traffic from any IP address. Narrow this down as necessary for your use case.
  }
  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allows all traffic
    cidr_blocks = ["0.0.0.0/0"] # Allows traffic to any IP address
  }

  tags = {
    Name = "mongoDB_sg"
  }
}

output "mongodb_instance_public_ip" {
  value = aws_instance.mongodb_instance.public_ip
}
