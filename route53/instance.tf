
resource "aws_instance" "IP_example" {
  ami           = lookup(var.ami_id, var.region)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_1.id

  # Security group assign to instance
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  private_ip             = "10.0.1.10"
  # key name
  key_name = aws_key_pair.key-tf.key_name

  user_data = <<EOF
    #! /bin/bash
    sudo yum update -y
    sudo yum install -y httpd.x86_64
    sudo service httpd start
    sudo service httpd enable
    echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
  EOF

  tags = {
    Name = "Private_IP"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.IP_example.id
  vpc      = true
}

output "elastic_ip" {
  value = aws_eip.eip.public_ip
}

# creating ssh-key.
resource "aws_key_pair" "key-tf" {
  key_name   = "key-tf"
  public_key = file("${path.module}/id_rsa.pub")
}
