variable "env" {
}

variable "corp" {
}

variable "vpc_id" {
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type = list(string)
}

variable "database_subnet_group" {
}

variable "elasticache_subnet_group" {
}

variable "available_zones" {
  type = list(string)
}

variable "lb_private_certificate_arn" {
}

variable "lb_public_certificate_arn" {
}

variable "frontend_api_repository_url" {
}
