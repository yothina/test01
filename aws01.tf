# version 1.2
provider "aws" {
  region     = "us-east-2"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "web" {
  ami           = "ami-03291866"
  instance_type = "t2.micro"
  key_name      = "aws01kp"
  associate_public_ip_address   = "true"
  tags{
        appname = "app1"
  }
  security_groups = [ "my_sg01" ]
}

resource "aws_security_group" "my_sg01" {
  name        = "my_sg01"
  description = "my_sg01"
}

resource "aws_security_group_rule" "ingress_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = 6
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.my_sg01.id}"
}

resource "aws_security_group_rule" "ingress_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = 6
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.my_sg01.id}"
}

# Create a new load balancer
resource "aws_elb" "my_elb01" {
  name               = "myelb01"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]


  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = ["${aws_instance.web.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    appname = "app1"
  }
}
