resource "google_service_account" "default" {
  account_id   = "minecraft-gce-sa-${var.name_suffix}"
  display_name = "Minecraft GCE Service Account"
}

resource "google_compute_address" "default" {
  name = "minecraft-${var.name_suffix}-ip"
}

resource "google_compute_resource_policy" "default" {
  name   = "minecraft-${var.name_suffix}-snapshot-schedule"
  region = "us-central1"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "08:00"
      }
    }

    retention_policy {
      max_retention_days    = 2
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
  }
}

resource "google_compute_disk" "default" {
  name  = "minecraft-${var.name_suffix}-disk"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20220506"
}

resource "google_compute_disk_resource_policy_attachment" "attachment" {
  name = google_compute_resource_policy.default.name
  disk = google_compute_disk.default.name
  zone = "us-central1-a"
}

resource "google_compute_instance" "default" {
  name                      = "minecraft-${var.name_suffix}-server"
  machine_type              = "c2-standard-8"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true

  boot_disk {
    auto_delete = false
    source      = google_compute_disk.default.id
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.default.address
    }

  }

  tags = ["minecraft-server"]

  metadata = {
    shutdown-script = var.shutdown_script
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }
}

output "instance_name" {
  value       = google_compute_instance.default.name
  description = "The name of the minecraft server instance"
}

output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
