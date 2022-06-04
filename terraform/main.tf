provider "google" {
  project = "abstract-code-308212"
  region  = "us-central1"
  zone    = "us-central1-a"
}

module "minecraft-one-eighteen" {
  source     = "./modules/minecraft"
  suffix     = "one-eighteen"
  domain     = "one.eighteen.jolley-minecraft.com"
  zone       = "us-central1-a"
  project_id = "abstract-code-308212"
}
