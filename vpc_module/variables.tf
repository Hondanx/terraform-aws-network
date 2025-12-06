variable "vpc_cidr" {
  description = "The IP range for the VPC"
  default     = "99.99.0.0/16"
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "public_subnets" {
  description = "CIDRs for the Public Subnets (Connected to IGW)"
  type        = list(string)
  # Matches your screenshot: 99.99.0.0/19 and 99.99.32.0/19
  default     = ["99.99.0.0/19", "99.99.32.0/19"]
}

variable "private_subnets" {
  description = "CIDRs for Private Subnets (Connected to NAT GW)"
  type        = list(string)
  # Matches your screenshot: 99.99.64.0/19 and 99.99.96.0/19
  default     = ["99.99.64.0/19", "99.99.96.0/19"]
}

variable "internal_subnets" {
  description = "CIDRs for Internal/DB Subnets (No Internet Access)"
  type        = list(string)
  # Matches your screenshot: 99.99.128.0/19 and 99.99.160.0/19
  default     = ["99.99.128.0/19", "99.99.160.0/19"]
}
