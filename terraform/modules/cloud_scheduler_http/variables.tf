variable "name" {
  type        = string
  description = "The name of the job"
}

variable "description" {
  type        = string
  description = "The description of the job"
}

variable "schedule" {
  type        = string
  description = "The cron schedule: e.g. */20 * * * *"
}

variable "url" {
  type        = string
  description = "the URL to hit with a GET request"
}
