# To get this up-and-running with the S3 back end I had to do:
#
#  terraform init -backend-config=terraform.tfvars

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# terraform {
#   backend "s3" {
#     bucket = "terraform-example-state-bucket"
#     key    = "terraform/example/state"
#     region = "eu-west-1"                      # No interpolations allowed
#   }
# }

# The public key was generated from the AWS .pem file using:
#
#  ssh-keygen -y -f <my-key-name>.pem > <my-key-name>.pub
#
# Note that if the key-pair is already in AWS it can be imported
# into Terraform with:
#
#   terraform import aws_key_pair.personal <my-key-name>
#
# which adds the key-pair to the Terraform state.
resource "aws_key_pair" "personal" {
  key_name   = "${var.key_name}"
  public_key = "${file("${var.public_key_filepath}")}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allows SSH"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_amqp" {
  name        = "allow_amqp"
  description = "Allows AMQP"

  # AMQP access from anywhere
  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "message-broker-host" {
  ami             = "${var.message_broker_ami}"         # Amazon Linux HVM
  instance_type   = "t2.small"
  key_name        = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.allow_amqp.id}"]
  count           = "${var.num_message_broker_hosts}"
}

resource "aws_instance" "worker-host" {
  ami             = "${var.celery_worker_ami}"         # Amazon Linux HVM
  instance_type   = "c4.8xlarge"
  key_name        = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  count           = "${var.num_celery_worker_hosts}"
}

resource "ansible_host" "message-broker-host" {
    inventory_hostname = "${element(aws_instance.message-broker-host.*.public_dns, count.index)}"
    groups = ["message-broker-hosts"]
    vars {
        ansible_user = "${var.message_broker_admin_username}"
    }
    count = "${var.num_message_broker_hosts}"
}

resource "ansible_host" "celery-worker-host" {
    inventory_hostname = "${element(aws_instance.worker-host.*.public_dns, count.index)}"
    groups = ["celery-worker-hosts"]
    vars {
        ansible_user = "${var.celery_worker_admin_username}"
    }
    count = "${var.num_celery_worker_hosts}"
}

resource "ansible_group" "message-broker-hosts" {
    inventory_group_name = "message-broker-hosts"
}

resource "ansible_group" "celery-worker-hosts" {
    inventory_group_name = "celery-worker-hosts"
}
