resource "google_dns_managed_zone" "default" {
  name     = var.zone_name
  dns_name = var.domain
}

resource "google_dns_record_set" "default" {
  name = "a-record.${google_dns_managed_zone.default.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.default.name

  rrdatas = [var.ip]
}
