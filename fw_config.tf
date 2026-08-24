resource "panos_security_rule_group" "example1" {
rule {
        name = "Deny sales to eng"
        source_zones = ["any"]
        source_addresses = ["any"]
        source_users = ["any"]
        destination_zones = ["any"]
        destination_addresses = ["any"]
        applications = ["any"]
        services = ["application-default"]
        categories = ["any"]
        action = "deny"
    }

    lifecycle {
        create_before_destroy = true
    }
 }

resource "panos_security_rule_group" "example2" {
rule {
        name = "ssl traffic"
        source_zones = ["any"]
        source_addresses = ["any"]
        source_users = ["any"]
        destination_zones = ["any"]
        destination_addresses = ["any"]
        applications = ["ssl"]
        services = ["any"]
        categories = ["any"]
        action = "deny"
    }

    lifecycle {
        create_before_destroy = true
    }
 }



resource "panos_address_object" "webhost-1" {
  name = "webhost-1"
  value = "10.200.0.30/32"
}

resource "panos_address_object" "webhost-2" {
  name = "webhost-2"
  value = "10.200.0.23/32"
}

resource "panos_address_object" "webhost-3" {
  name = "webhost-3"
  value = "10.200.0.24/32"
}


 resource "panos_address_object" "webhost-4" {
  name = "webhost-4"
  value = "10.200.0.25/32"
}

resource "panos_address_object" "webhost-5" {
  name = "webhost-5"
  value = "10.200.0.26/32"
}

 resource "panos_address_object" "webhost-6" {
  name = "webhost-6"
  value = "10.200.0.27/32"
}

resource "panos_address_object" "webhost-7" {
  name = "webhost-7"
  value = "10.200.0.28/32"
}

 resource "panos_address_object" "webhost-11" {
  name = "webhost-11"
  value = "10.200.0.40/32"
}

resource "panos_address_object" "webhost-12" {
  name = "webhost-12"
  value = "10.200.0.41/32"
}