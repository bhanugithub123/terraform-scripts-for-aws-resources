provider "aws" {
  region     = "us-east-2"
  access_key = "enter your access key"
  secret_key = "enter your secret key"
}
# instances details
resource "aws_instance" "test" {
  ami                    = "ami-0960ab670c8bb45f3"
  instance_type          = "t2.micro"
  count                  = 2
  key_name               = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  user_data              = <<-EOF
          #!/bin/bash
        
          yum install httpd -y

          echo "hey i am $(hostname -f)" > /var/www/html/index.html
          service httpd start
          chkconfig httpd on
          EOF

  tags = {
    "name" = "harish${count.index}"
  }
}

# keypair
resource "aws_key_pair" "keypair" {
  key_name   = "firsttf"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEL1ymGk2Ib/O6aRihZm6KwbIhjqCgVM72ZXcZuYIH/966hLEW608GfQpNDd739C5KF+1KO4H6Y5oz22kartR6stss2Q+nO5/b/+QzfmGQH9RKvb1B7X+GVYvHkXbcPM9lYQEFiYL50M7W03h6q9giXwMYHUWjszBf+vqma42OV1L1OhLCQE73Io5MGWwtiCh2RlbTHmp1t5Kw98fYgfyFRcNPhPbJsu7+31FG6EktBwWXlvwZbef01rjcpA3y/5BXL/mXX/vae+Z1uTJlpzOK+kH2kc018qoTZbV0nBHodVztCXop9GZ5N7gh+BXuPnWjo2JfU9jUuYVPA4xIApGhTjs8lSqeDhBL2iSgVuvbc7TCId43gjx2d2FMnOTO6a8+OCX608CrD7hhLCOtrsInTpjKmqQECq45CI4k6V5sF3Oc3MiQ5Y9ECGnC571Fsj1UJnWvuDHdcFiccyaqGwYYC8C8N4JPtUZMRbIKFNR7lmY2YHVwDLyUyhRs0gSXfa8= harishdhakad@harish"

}
# elastic ip 
resource "aws_eip" "myeip" {
  count    = length(aws_instance.test)
  vpc      = true
  instance = element(aws_instance.test.*.id, count.index)

  tags = {
    name = "eip-test${count.index}"
  }
}

#    vpc
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default Vpc"

  }
}

# security group
resource "aws_security_group" "allow_ports" {
  name        = "alb"
  description = "Allow inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
    ingress {
    description = "http from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "http from VPC"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
    ingress {
    description = "http from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_ports"
  }
}

data "aws_subnet_ids" "subnet" {
  vpc_id = aws_default_vpc.default.id
}
#  elb target group
resource "aws_lb_target_group" "test" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    # unhealthy_thershold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_lb" "my-aws-alb" {
  name               = "harishtest-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_ports.id}"]
  subnets             = data.aws_subnet_ids.subnet.ids
  tags = {
    Name = "harish-test-alb"
  }
  ip_address_type = "ipv4"

}


resource "aws_lb_listener" "harish-test-alb-listner" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_listener" "harish-test-alb-listner1" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}
resource "aws_lb_listener" "harish-test-alb-listner2" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  count            = length(aws_instance.test)
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.test[count.index].id
}

