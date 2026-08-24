
variable "hostname" {
  default     = "PaloGitHubAgenticAITest1"
  description = "The hostname of the VM-series instance"
  type        = string
}

variable "panorama-server" {
  description = "The FQDN or IP address of the primary Panorama server"
  type        = string
}

variable "device-group" {
  default     = "DG1"
  description = "The Panorama device group that receives the security rules"
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

