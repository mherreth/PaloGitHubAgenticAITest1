
variable "hostname" {
  default     = "PaloGitHubAgenticAITest1"
  description = "The hostname of the VM-series instance"
  type        = string
}

variable "panorama-server" {
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
  default     = "Janelle_2017#"
  description = "password"
  type        = string
}

