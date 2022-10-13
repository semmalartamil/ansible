locals {
  vpc_id           = "vpc-8791faec"
  subnet_id        = "subnet-4c72bb31"
  ssh_user         = "ec2-user"
  key_name         = "chan"
  private_key_path = "C:/project5/chan.pem"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "ami-092b43193629811af"
  subnet_id                   = "subnet-4c72bb31"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name
   
  tags = { 
    Name= "ANSIBLE" 
  }
  provisioner "file" {
        source="script.sh"
        destination="/tmp/script.sh"
  }
  provisioner "remote-exec" {
     inline=[
       "chmod +x /tmp/script.sh",
       "sudo /tmp/script.sh"
     ]
  }
  connection {
     type        = "ssh"
     user        = "ec2-user"
     private_key = "${file("chan.pem")}"
     host        = "${aws_instance.web.public_ip}"
  }
  provisioner "remote-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
}