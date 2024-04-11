variable "project" {
  type    = string
  default = "cloud-internship-aerdeljan"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-c"
}

variable "network_name_prefix" {
  type    = string
  default = "network"
}

variable "subnet_name_prefix" {
  type    = string
  default = "subnet"
}

variable "firewall_name_prefix" {
  type    = string
  default = "firewall"
}

variable "vm_template_name_prefix" {
  type    = string
  default = "vm"
}

variable "instance_group_manager_name_prefix" {
  type    = string
  default = "instance-manager"
}

variable "health_check_name_prefix" {
  type    = string
  default = "health-check"
}

variable "load_balancer_name_prefix" {
  type    = string
  default = "load-balancer"
}

variable "url_map_name_prefix" {
  type    = string
  default = "http-mapping"
}

variable "http_proxy_name_prefix" {
  type    = string
  default = "proxy-mapper"
}

variable "forwarding_rule_name_prefix" {
  type    = string
  default = "content-rule"
}

variable "subnet_ip_cidr_range" {
  type    = string
  default = "10.10.0.0/24"
}

variable "vm_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "source_image" {
  type    = string
  default = "projects/debian-cloud/global/images/debian-12-bookworm-v20240312"
}

variable "startup_script_path" {
  type    = string
  default = "docker-install.sh"
}

variable "service_account_email" {
  type    = string
  default = "cloud-internship-aerdeljan@appspot.gserviceaccount.com"
}

variable "scopes" {
  type    = list(string)
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "http_health_check_port" {
  type    = number
  default = 80
}

variable "target_size" {
  type    = number
  default = 2
}
