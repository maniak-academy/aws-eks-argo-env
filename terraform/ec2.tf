resource "aws_instance" "mongodb_instance" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
subnet_id       = module.vpc.public_subnets[0]
  key_name        = "us-east-1key"
  associate_public_ip_address = true  # This line is added to associate a public IP
  vpc_security_group_ids      = [aws_security_group.MongoDB_sg.id] # Attach the security group

  tags = {
    Name = "MongoDBInstance"
  }

  # User data script to install MongoDB
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y gnupg
              wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
              echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
              sudo apt-get update
              sudo apt-get install -y mongodb-org
              sudo systemctl start mongod
              sudo systemctl enable mongod
              EOF
}

resource "aws_security_group" "MongoDB_sg" {
  name        = "MongoDB_sg"
  description = "Allow inbound traffic on port 80 and all outbound traffic"
  vpc_id      = module.vpc.vpc_id  # Replace this with your VPC ID if needed

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Allows traffic from any IP address. Narrow this down as necessary for your use case.
  }
  egress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # Allows all traffic
    cidr_blocks      = ["0.0.0.0/0"] # Allows traffic to any IP address
  }

  tags = {
    Name = "mongoDB_sg"
  }
}