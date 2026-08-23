
variable "hostname" {
  default     = "PaloGitHubAgenticAITest1"
  description = "The hostname of the VM-series instance"
  type        = string
}

variable "panorama_server" {
  default     = "192.168.1.109"
  description = "The FQDN or IP address of the primary Panorama server"
  type        = string
}

variable "username" {
  default     = "admin"
  description = "username"
  type        = string
}

variable "password" {
  description = "password"
  sensitive   = true
  type        = string
}
