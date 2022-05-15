variable "name_suffix" {
  type        = string
  description = "The unique identifier to tag all the resource names with"
}

variable "shutdown_script" {
  type        = string
  description = "The shutdown script for this instance"
  default     = "echo 'goodbye'"
}
