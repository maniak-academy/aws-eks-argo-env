variable "region" {
  type    = string
  default = "us-east-1"
}

##################

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 2
}

variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  # description = "Name of the project deployment."
  type    = string
  default = "eks-maniak"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "172.16.0.0/16"
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 4
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "TerraformEKSManiak"
    "Environment" = "Development"
    "Owner"       = "sebastian@maniak.io"
  }
}
variable "allow-ips-bastion" {
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  type        = list(any)
  description = "Bastion IPs"
}

variable "settings" {
  description = "Additional key value pair for cluster-autoscaler"
  type        = map(any)
  default     = {}
}