#############################
#  Elasticsearch Variables  #
#############################

# GLOBAL VARIABLES HERE IF NEEDED

##########################
#  Import VPC Variables  #
##########################

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "sre-testing"
}
######################################
#  Elasticsearch Host EC2 Variables  #
######################################

variable "es_instance_type" {
  description = "The instance type for the Elasticsearch host"
  type        = string
  default     = "t2.large"
}

variable "es_ec2_ami" {
  description = "The AMI for the Elasticsearch host"
  type        = string
  default     = "Ubuntu"
}

variable "es_subnet_id" {
  description = "The subnet ID for the Elasticsearch host"
  type        = string
  default     = ""
}

variable "es_key_name" {
  description = "The key-pair name for the Elasticsearch host"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "The IAM instance profile for the Elasticsearch host"
  type        = string
  default     = "ec2-admin"
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the Elasticsearch host"
  type        = bool
  default     = false
}

variable "delete_on_termination" {
  description = "Delete the root volume on termination"
  type        = bool
  default     = true
}

variable "es_host_volume_size" {
  description = "The volume size for the Elasticsearch host"
  type        = number
  default     = 100
}

variable "es_host_volume_type" {
  description = "The volume type for the Elasticsearch host"
  type        = string
  default     = "gp3"
}

