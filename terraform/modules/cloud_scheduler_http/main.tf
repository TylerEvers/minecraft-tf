resource "google_cloud_scheduler_job" "default" {
  name             = var.name
  description      = var.description
  schedule         = var.schedule
  time_zone        = "America/Boise"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = var.url
  }
}
