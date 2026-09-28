variable "project_id" {
  description = "GCP project ID where the infrastructure will be created."
  type        = string
}

variable "region" {
  description = "GCP region for regional resources."
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "GCP zone for single-zone Compute Engine instances."
  type        = string
  default     = "asia-northeast1-a"
}

variable "name_prefix" {
  description = "Prefix used for resource names. Use lower-case letters, numbers, and hyphens."
  type        = string
  default     = "dialog"

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,18}[a-z0-9])?$", var.name_prefix))
    error_message = "name_prefix must be 1-20 characters and use lower-case letters, numbers, and hyphens."
  }
}

variable "subnet_cidr" {
  description = "CIDR range for the private subnet used by the VMs."
  type        = string
  default     = "10.10.0.0/24"
}

variable "allowed_ssh_ranges" {
  description = "Optional CIDR ranges that can SSH to the VMs. Empty by default."
  type        = list(string)
  default     = []
}

variable "app_machine_type" {
  description = "Machine type for app instances."
  type        = string
  default     = "e2-medium"
}

variable "monitor_machine_type" {
  description = "Machine type for the monitor instance."
  type        = string
  default     = "e2-medium"
}

variable "function_image_tag" {
  description = "Tag of the function container image in the Terraform-managed Artifact Registry repository. Use an immutable tag for each release."
  type        = string
  default     = "latest"

  validation {
    condition     = can(regex("^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$", var.function_image_tag))
    error_message = "function_image_tag must be a valid Docker tag of at most 128 characters."
  }
}