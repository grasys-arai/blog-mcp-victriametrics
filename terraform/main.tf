locals {
  labels = merge(
    {
      managed_by = "terraform"
      stack      = var.name_prefix
    },
  )

  required_services = toset([
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "run.googleapis.com",
  ])
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

data "google_compute_image" "rocky_linux" {
  family  = "rocky-linux-10"
  project = "rocky-linux-cloud"
}

resource "google_compute_network" "main" {
  name                    = "${var.name_prefix}-blog-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name                     = "${var.name_prefix}-subnet"
  ip_cidr_range            = var.subnet_cidr
  network                  = google_compute_network.main.id
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name_prefix}-allow-internal"
  network = google_compute_network.main.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name_prefix}-allow-ingress"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = [
      "22",
      "3000",
      "8081",
      "8428",
    ]
  }

  source_ranges = var.allowed_ssh_ranges
  target_tags   = ["${var.name_prefix}-vm"]
}

resource "google_service_account" "vm" {
  account_id   = "${var.name_prefix}-vm"
  display_name = "${var.name_prefix} Compute Engine service account"
}

resource "google_compute_address" "app" {
  name   = "${var.name_prefix}-app-ip"
  region = var.region
}

resource "google_compute_instance" "app" {
  name         = "${var.name_prefix}-app"
  machine_type = var.app_machine_type
  zone         = var.zone
  tags         = ["${var.name_prefix}-app", "${var.name_prefix}-vm"]
  labels       = merge(local.labels, { component = "app" })

  boot_disk {
    initialize_params {
      image = data.google_compute_image.rocky_linux.self_link
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id

    access_config {
      nat_ip = google_compute_address.app.address
    }
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_address" "monitor" {
  name   = "${var.name_prefix}-monitor-ip"
  region = var.region
}

resource "google_compute_instance" "monitor" {
  name         = "${var.name_prefix}-monitor"
  machine_type = var.monitor_machine_type
  zone         = var.zone
  tags         = [ "${var.name_prefix}-vm"]
  labels       = merge(local.labels, { component = "monitor" })

  boot_disk {
    initialize_params {
      image = data.google_compute_image.rocky_linux.self_link
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id

    access_config {
      nat_ip = google_compute_address.monitor.address
    }
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }
}
