provider "google" {
  project = "techflow-dev"
  region = "us-central1"
}
module "storage" {
  source = "./modules/storage"
  bucket_name = "techflow-dev-bucket"
}

module "network" {
  source = "./modules/network"
  vpc_name = "techflow-vpc"
  region = "us-central1"
}