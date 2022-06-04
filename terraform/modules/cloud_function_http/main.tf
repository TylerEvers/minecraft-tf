resource "google_storage_bucket" "default" {
  name     = "${var.name}-src-bucket"
  location = "US"
}

data "archive_file" "default" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.source_zip
}

resource "google_storage_bucket_object" "default" {
  name   = "index.${substr(data.archive_file.default.output_md5, 0, 5)}.zip"
  bucket = google_storage_bucket.default.name
  source = var.source_zip
}

resource "google_cloudfunctions_function" "default" {
  name        = var.name
  description = var.description
  runtime     = "nodejs14"

  available_memory_mb   = var.memory
  source_archive_bucket = google_storage_bucket.default.name
  source_archive_object = google_storage_bucket_object.default.name
  trigger_http          = true
  entry_point           = var.entry_point
  environment_variables = var.environment_variables
  service_account_email = var.service_account_email
}


# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "default" {
  project        = google_cloudfunctions_function.default.project
  region         = google_cloudfunctions_function.default.region
  cloud_function = google_cloudfunctions_function.default.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

output "url" {
  value       = google_cloudfunctions_function.default.https_trigger_url
  description = "Cloud Function URL"
}
