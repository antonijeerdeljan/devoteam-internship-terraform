resource "google_compute_network" "project_vpc" {
  name = "network-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "project_subnet_us_central" {
  name = "subnet-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  ip_cidr_range = "10.10.0.0/24"
  network       = google_compute_network.project_vpc.id
  region        = var.region

}

resource "google_compute_firewall" "firewall_rules" {
  name = "firewall-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  network = google_compute_network.project_vpc.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  priority = 1000
}


resource "google_compute_instance_template" "devoteam-vm" {
  name         = "vm-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  machine_type = "e2-medium"
  region       = var.region

  network_interface {
    network    = google_compute_network.project_vpc.id
    subnetwork = google_compute_subnetwork.project_subnet_us_central.id
    access_config {
    }
  }

  disk {
    auto_delete  = true
    boot         = true
    device_name  = "disk-${formatdate("YYYYMMDDHHmmss", timestamp())}"
    source_image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240312"
    mode         = "READ_WRITE"
  }

  service_account {
    email  = "cloud-internship-aerdeljan@appspot.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = file("docker-install.sh")

  lifecycle {
    create_before_destroy = true
  }
}



resource "google_compute_instance_group_manager" "devoteam-vm-group" {
  name = "instance-manager-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  zone = var.zone

  named_port {
    name = "http"
    port = 80
  }

  version {
    instance_template = google_compute_instance_template.devoteam-vm.id
    name              = "primary"
  }

  base_instance_name = "vm"
  target_size        = 2

  lifecycle {
    create_before_destroy = true
  }

}

resource "google_compute_health_check" "devoteam-health-check" {
  name                = "health-check-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  check_interval_sec  = 5
  unhealthy_threshold = 2
  http_health_check {
    port               = 80
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
    request_path       = "/"
  }


}

resource "google_compute_backend_service" "devoteam-load-balancer" {
  name                            = "load-balancer-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  connection_draining_timeout_sec = 0
  health_checks                   = [google_compute_health_check.devoteam-health-check.id]
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  port_name                       = "http"
  protocol                        = "HTTP"
  session_affinity                = "NONE"
  timeout_sec                     = 30
  backend {
    group           = google_compute_instance_group_manager.devoteam-vm-group.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }


}

resource "google_compute_url_map" "url-mapper" {
  name            = "http-mapping-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  default_service = google_compute_backend_service.devoteam-load-balancer.id
}

resource "google_compute_target_http_proxy" "proxy" {
  name    = "proxy-mapper-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  url_map = google_compute_url_map.url-mapper.id


}

resource "google_compute_global_forwarding_rule" "forward" {
  name                  = "content-rule-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.proxy.id
}