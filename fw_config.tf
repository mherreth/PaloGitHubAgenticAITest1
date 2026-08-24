resource "panos_panorama_security_rule_group" "example1" {
  device_group = var.device-group
  rulebase     = "pre-rulebase"
  rule {
    name                  = "Deny sales to eng"
    source_zones          = ["any"]
    source_addresses      = ["any"]
    source_users          = ["any"]
    destination_zones     = ["any"]
    destination_addresses = ["any"]
    applications          = ["any"]
    services              = ["application-default"]
    categories            = ["any"]
    action                = "deny"
  }
}

resource "panos_panorama_security_rule_group" "example2" {
  device_group = var.device-group
  rulebase     = "pre-rulebase"
  rule {
    name                  = "ssl traffic"
    source_zones          = ["any"]
    source_addresses      = ["any"]
    source_users          = ["any"]
    destination_zones     = ["any"]
    destination_addresses = ["any"]
    applications          = ["ssl"]
    services              = ["any"]
    categories            = ["any"]
    action                = "deny"
  }
}



resource "panos_panorama_address_object" "webhost-1" {
  device_group = var.device-group
  name  = "webhost-1"
  value = "10.200.0.30/32"
}

resource "panos_panorama_address_object" "webhost-2" {
  device_group = var.device-group
  name  = "webhost-2"
  value = "10.200.0.23/32"
}

resource "panos_panorama_address_object" "webhost-3" {
  device_group = var.device-group
  name  = "webhost-3"
  value = "10.200.0.24/32"
}


 resource "panos_panorama_address_object" "webhost-4" {
  device_group = var.device-group
  name  = "webhost-4"
  value = "10.200.0.25/32"
}

resource "panos_panorama_address_object" "webhost-5" {
  device_group = var.device-group
  name  = "webhost-5"
  value = "10.200.0.26/32"
}

 resource "panos_panorama_address_object" "webhost-6" {
  device_group = var.device-group
  name  = "webhost-6"
  value = "10.200.0.27/32"
}

resource "panos_panorama_address_object" "webhost-7" {
  device_group = var.device-group
  name  = "webhost-7"
  value = "10.200.0.28/32"
}

 resource "panos_panorama_address_object" "webhost-11" {
  device_group = var.device-group
  name  = "webhost-11"
  value = "10.200.0.40/32"
}

resource "panos_panorama_address_object" "webhost-12" {
  device_group = var.device-group
  name  = "webhost-12"
  value = "10.200.0.41/32"
}

resource "panos_panorama_address_object" "webhost-13" {
  device_group = var.device-group
  name  = "webhost-13"
  value = "10.200.0.42/32"
}

resource "panos_panorama_address_object" "webhost-14" {
  device_group = var.device-group
  name         = "webhost-14"
  value        = "10.200.0.43/32"
}

resource "panos_panorama_address_object" "webhost-15" {
  device_group = var.device-group
  name  = "webhost-15"
  value = "10.200.0.44/32"
}

resource "panos_panorama_address_object" "webhost-16" {
  device_group = var.device-group
  name         = "webhost-16"
  value        = "10.200.0.45/32"
}

resource "panos_panorama_address_object" "webhost-17" {
  device_group = var.device-group
  name         = "webhost-17"
  value        = "10.200.0.46/32"
}

resource "panos_panorama_address_object" "webhost-18" {
  device_group = var.device-group
  name         = "webhost-18"
  value        = "10.200.0.47/32"
}

resource "panos_panorama_address_object" "webhost-19" {
  device_group = var.device-group
  name         = "webhost-19"
  value        = "10.200.0.48/32"
}