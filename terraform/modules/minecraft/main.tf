module "service_account" {
  source      = "../iam"
  project_id  = var.project_id
  name_suffix = var.suffix
}

module "minecraft_gce" {
  source                = "../compute"
  name_suffix           = var.suffix
  shutdown_script       = file("${path.module}/shutdown.sh")
  service_account_email = module.service_account.email
}

module "dns" {
  source     = "../dns"
  ip         = module.minecraft_gce.ip
  suffix     = var.suffix
  depends_on = [module.minecraft_gce]
}

module "server_status_fn" {
  source      = "../cloud_function_http"
  name        = "get-server-status-${var.suffix}"
  description = "Function to check the current status of the minecraft server"
  entry_point = "stats"
  environment_variables = {
    IP         = module.minecraft_gce.ip
    PROJECT_ID = var.project_id
  }
  source_zip            = "../get-server-status-cloud-fn/target/index.zip"
  source_dir            = "../get-server-status-cloud-fn/src"
  service_account_email = module.service_account.email
  depends_on            = [module.dns]
}

module "shutdown_empty_server_fn" {
  source      = "../cloud_function_http"
  name        = "shutdown-empty-server-${var.suffix}"
  description = "Function to check the current status of the minecraft server"
  entry_point = "shutdownWhenNotInUse"
  memory      = 256
  environment_variables = {
    ZONE                       = var.zone
    COMPUTE_INSTANCE           = module.minecraft_gce.instance_name
    DOMAIN                     = "${module.dns.domain}."
    SERVER_STATUS_CLOUD_FN_URL = module.server_status_fn.url
    PROJECT_ID                 = var.project_id
  }
  source_zip            = "../shutdown-empty-server-cloud-fn/target/index.zip"
  source_dir            = "../shutdown-empty-server-cloud-fn/src"
  service_account_email = module.service_account.email
  depends_on            = [module.dns]
}

module "startup_fn" {
  source      = "../cloud_function_http"
  name        = "startup-server-${var.suffix}"
  description = "Function to startup the minecraft server"
  entry_point = "startServer"
  memory      = 256
  environment_variables = {
    ZONE                       = var.zone
    COMPUTE_INSTANCE           = module.minecraft_gce.instance_name
    DOMAIN                     = "${module.dns.domain}"
    SERVER_STATUS_CLOUD_FN_URL = module.server_status_fn.url
    PROJECT_ID                 = var.project_id
    IP                         = module.minecraft_gce.ip
  }
  source_zip            = "../startup-cloud-fn/target/index.zip"
  source_dir            = "../startup-cloud-fn/src"
  service_account_email = module.service_account.email
  depends_on            = [module.dns]
}

module "shutdown_schedule" {
  source      = "../cloud_scheduler_http"
  name        = "shutdown-empty-server-${var.suffix}"
  description = "Every 20 minutes, call shutdown-empty-server-${var.suffix}"
  schedule    = "*/20 * * * *"
  url         = module.shutdown_empty_server_fn.url
}
