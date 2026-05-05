resource "google_compute_network" "vpc" {
    name = var.vpc_name
    auto_create_subnetworks = false
  
}

resource "google_compute_subnetwork" "private" {
    name = "${var.vpc_name}-private"
    network = google_compute_network.vpc.id
    region = var.region
    ip_cidr_range = "10.10.2.0/24"

    private_ip_google_access = true 
  
}