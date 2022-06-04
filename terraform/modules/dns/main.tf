locals {
  domain = "jolley-minecraft.com."
}
resource "google_dns_managed_zone" "default" {
  name     = "jolley-minecraft-com"
  dns_name = local.domain
}

resource "google_dns_record_set" "root_a" {
  name = substr(local.domain, 0, -1)
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.default.name

  rrdatas = [var.ip]
}

resource "google_dns_record_set" "subdomain_a" {
  name = substr("${var.suffix}.${google_dns_managed_zone.default.dns_name}", 0, -1)
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.default.name

  rrdatas = [var.ip]
}

data "google_dns_record_set" "soa" {
  name = local.domain
  type = "SOA"
  // ttl          = 21600
  managed_zone = google_dns_managed_zone.default.name
  /* rrdatas      = ["ns-cloud-e1.googledomains.com. cloud-dns-hostmaster.google.com. 1 21600 3600 259200 300"] */
}

data "google_dns_record_set" "ns" {
  name = local.domain
  type = "NS"
  // ttl          = 21600
  managed_zone = google_dns_managed_zone.default.name

  /* rrdatas = [
    "ns-cloud-e1.googledomains.com.",
    "ns-cloud-e2.googledomains.com.",
    "ns-cloud-e3.googledomains.com.",
    "ns-cloud-e4.googledomains.com."
  ]*/

}

output "domain" {
  value = substr("${var.suffix}.${google_dns_managed_zone.default.dns_name}", 0, -1)
}
