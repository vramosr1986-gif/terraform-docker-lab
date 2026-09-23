variable "nginx_port" {
  description = "Puerto externo para nginx"
  type        = number
  default     = 8080
}

variable "postgres_password" {
  description = "Password de postgres"
  type        = string
  sensitive   = true
}