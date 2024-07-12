variable "cidr_block" {
  type        = string
  description = "CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  type        = list(string)
  description = "Availability zones for VPC"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidr_block" {
  type        = map(string)
  description = "CIDR Block for Public Subnet"
  default = {
    "us-east-1a" = "10.0.1.0/24",
    "us-east-1b" = "10.0.2.0/24"
  }
}

variable "private_subnet_cidr_block" {
  type        = map(string)
  description = "CIDR Block for Private Subnet"
  default = {
    "us-east-1a" = "10.0.3.0/24",
    "us-east-1b" = "10.0.4.0/24"
  }
}

variable "environment-name" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

variable "vpc-name" {
  description = "The VPC name"
  type        = string
  default     = "primary"
}

variable "key_name" {
  description = "Key Pair for SSH"
  type        = string
  default     = "id_rsa"
}

