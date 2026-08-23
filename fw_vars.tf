
variable "hostname" {
  default     = "PaloGitHubAgenticAITest1"
  description = "The hostname of the VM-series instance"
  type        = string
}

variable "panos_hostname" {
  description = "The FQDN or IP address of the PAN-OS device"
  type        = string
}

variable "panos_username" {
  description = "PAN-OS username"
  type        = string
}

variable "panos_password" {
  description = "PAN-OS password"
  type        = string
  sensitive   = true
}
