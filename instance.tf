provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_role_policy" "opensearch_iam_policy" {
  name = "test_policy"
  role = aws_iam_role.opensearch_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
         {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "aoss:APIAccessAll",
            "Resource": "arn:aws:aoss:us-east-2:909293070315:collection/collection-id"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "aoss:DashboardsAccessAll",
            "Resource": "arn:aws:aoss:us-east-2:909293070315:dashboards/default"
        }
    ]
}
  )
}

resource "aws_iam_role" "opensearch_role" {
  name = "opensearch_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_instance_profile" "openseach_profile" {
  name = "openseach_profile"
  role = aws_iam_role.opensearch_role.name
}

data "aws_ami" "logstast-ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230628.0-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_security_group" "logstash-sg" {
  name        = "logstash-sg"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_instance" "web" {
  ami           = data.aws_ami.logstast-ami.id
  instance_type = var.instance_type
  iam_instance_profile  = "${aws_iam_instance_profile.openseach_profile.name}"
  vpc_security_group_ids = [aws_security_group.logstash-sg.id]
  user_data = "${file("install_logstash.sh")}"

  tags = {
    Name = "logstash_instance"
    owner = "ranjiniganeshan@gmail.com"
  }
}
