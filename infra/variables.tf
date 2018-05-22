variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "eu-west-1"
}

variable "key_name" {
  description = "The AWS key pair name"
}

variable "public_key_filepath" {
  description = "The public key (*.pub) filepath"
}

# For AWS EC2 spot instances, we're allowed 20 in total

variable "num_message_broker_hosts" {
    default = 1
}

variable "num_celery_worker_hosts" {
    default = 19
}

variable "message_broker_ami" {
    default = "ami-705d6a09"  # Ubuntu 17.10 EBS / previously Ubuntu 16.04 "ami-f90a4880"
}

variable "celery_worker_ami" {
    default = "ami-705d6a09"  # Ubuntu 17.10 EBS / previously Ubuntu 16.04 "ami-f90a4880"
}

variable "message_broker_admin_username" {
    default = "ubuntu"
}

variable "celery_worker_admin_username" {
    default = "ubuntu"
}
