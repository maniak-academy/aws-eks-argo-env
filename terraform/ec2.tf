resource "aws_instance" "mongodb_instance" {
  ami                         = "ami-080e1f13689e07408"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = "us-east-1key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.MongoDB_sg.id]

  tags = {
    Name = "MongoDBInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install gnupg curl -y
              curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
              sudo apt-get update -y
              sudo apt-get install -y mongodb-org
              sudo systemctl start mongod
              sudo systemctl enable mongod
              EOF
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
    cidr_blocks = ["0.0.0.0/0"] # Allows traffic from any IP address. Narrow this down as necessary for your use case.
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