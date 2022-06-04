resource "google_service_account" "default" {
  account_id   = "minecraft-gce-sa-${var.name_suffix}"
  display_name = "Minecraft GCE Service Account"
}

resource "google_project_iam_member" "default" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.default.email}"
}

output "email" {
  value = google_service_account.default.email
}
