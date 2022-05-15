variable "name" {
  type        = string
  description = "the name of the function"
}

variable "description" {
  type        = string
  description = "the description of the function"
}

variable "entry_point" {
  type        = string
  description = "the name of the function to call"
}

variable "source_zip" {
  type        = string
  description = "the path to the source zip"
}

variable "environment_variables" {
  type = map(string)
}

variable "memory" {
  type        = number
  description = "how much ram"
  default     = 128
}
