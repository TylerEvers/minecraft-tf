variable "suffix" {
  type        = string
  description = "The suffix to append to every resource created by this module"
}

variable "domain" {
  type        = string
  description = "The domain name to make for this server"
}

variable "zone" {
  type        = string
  description = "the GCP zone to create resources in"
}

variable "project_id" {
  type        = string
  description = "the project id"
}
