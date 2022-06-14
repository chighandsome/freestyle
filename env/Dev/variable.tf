variable "region" {
  description = "The region where environment is going to be deployed"
  type        = string
  default     = "us-east-1"
}


# VPC variables

variable "vpc_cidr" {
  description = "CIDR range for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "priv1_cidr" {
  description = "CIDR range for private subnet 1"
  type        = string
  default     = "10.0.6.0/24"

}

variable "priv2_cidr" {
  description = "CIDR range for private subnet 2"
  type        = string
  default     = "10.0.7.0/24"

}

variable "pub1_cidr" {
  description = "CIDR range of public subnet 1"
  type        = string
  default     = "10.0.8.0/24"
}

variable "pub2_cidr" {
  description = "CIDR range of public subnet 1"
  type        = string
  default     = "10.0.9.0/24"
}

variable "env" {
  description = "work environment"
  type        = string
  default     = "Dev"

}

