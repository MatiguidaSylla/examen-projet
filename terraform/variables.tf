variable "region" {
  description = "AWS region"
  default     = "eu-west-3" # Paris par exemple
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
}
