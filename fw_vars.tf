
variable "hostname" {
  default     = "PaloGitHubAgenticAITest1"
  description = "The hostname of the VM-series instance"
  type        = string
}

variable "panorama-server" {
  description = "The FQDN or IP address of the primary Panorama server"
  type        = string
}

variable "username" {
  description = "username"
  type        = string
}

variable "password" {
  description = "password"
  type        = string
  sensitive   = true
}

