resource "google_compute_network" "project_vpc" {
  name                    = "${var.network_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "project_subnet_us_central" {
  name          = "${var.subnet_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  ip_cidr_range = var.subnet_ip_cidr_range
  network       = google_compute_network.project_vpc.id
  region        = var.region
}

resource "google_compute_firewall" "firewall_rules" {
  name    = "${var.firewall_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  network = google_compute_network.project_vpc.id
  allow {
    protocol = ["tcp", "icmp"]
    ports    = ["80", "22"]
  }
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
}

resource "google_compute_instance_template" "devoteam_vm" {
  name         = "${var.vm_template_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  machine_type = var.vm_machine_type
  region       = var.region
  network_interface {
    network    = google_compute_network.project_vpc.id
    subnetwork = google_compute_subnetwork.project_subnet_us_central.id
  }
  disk {
    auto_delete = true
    boot        = true
    source_image = var.source_image
    device_name  = "${var.vm_template_name_prefix}-disk-${formatdate("YYYYMMDDHHmmss", timestamp())}"
    mode         = "READ_WRITE"
  }
  service_account {
    email  = var.service_account_email
    scopes = var.scopes
  }
  metadata_startup_script = file(var.startup_script_path)
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "devoteam_vm_group" {
  name               = "${var.instance_group_manager_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  zone               = var.zone
  base_instance_name = var.vm_template_name_prefix
  target_size        = var.target_size
  version {
    instance_template = google_compute_instance_template.devoteam_vm.id
    name              = "primary"
  }
  named_port {
    name = "http"
    port = var.http_health_check_port
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "devoteam_health_check" {
  name               = "${var.health_check_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  check_interval_sec = 5
  unhealthy_threshold = 2
  http_health_check {
    port = var.http_health_check_port
  }
}

resource "google_compute_backend_service" "devoteam_load_balancer" {
  name                          = "${var.load_balancer_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  health_checks                 = [google_compute_health_check.devoteam_health_check.id]
  load_balancing_scheme         = "EXTERNAL"
  protocol                      = "HTTP"
  backend {
    group = google_compute_instance_group_manager.devoteam_vm_group.instance_group
  }
}

resource "google_compute_url_map" "url_mapper" {
  name            = "${var.url_map_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  default_service = google_compute_backend_service.devoteam_load_balancer.id
}

resource "google_compute_target_http_proxy" "proxy" {
  name    = "${var.http_proxy_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  url_map = google_compute_url_map.url_mapper.id
}

resource "google_compute_global_forwarding_rule" "forward" {
  name       = "${var.forwarding_rule_name_prefix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  target     = google_compute_target_http_proxy.proxy.id
  port_range = "80"
}
