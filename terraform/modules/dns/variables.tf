variable "ip" {
  type        = string
  description = "The ip to bind the dns entry to"
}

variable "zone_name" {
  type        = string
  description = "The name of the zone in google"
}

variable "domain" {
  type        = string
  description = "the domain/zone you want to create"
  validation {
    condition     = can(regex("\\.$", var.domain))
    error_message = "Domain must end with a period."
  }
}
