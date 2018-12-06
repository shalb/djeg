variable "name" {
  description = "The Environment Name"
  default     = "djeg"
}

variable "region" {
  description = "The AWS region to create resources in."
  default = "eu-central-1"
}

variable "availability_zone" {
  description = "The availability zone"
}

variable "instance_type" {
  description = "The instance type."
}

variable "amis" {
  type        = "map"
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
  default     = {}
}

variable "data_volume_mount_path" {
  description = "Path to mount the ELK data volume"
  default     = "/dev/xvdh"
}

variable "dns_zonename" {
  description = "DNS zone name"
  default     = ""
}

variable "dns_zone_id" {
  description = "DNS zone name"
  default     = ""
}

variable "djeg_version" {
  description = "Please define a version of DJEG"
  default     = ""
}
