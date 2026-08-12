package terraform.security

import rego.v1

deny contains violation if {
	some resource in active_resource_changes
	resource.type == "aws_security_group"
	some rule in object.get(resource.change.after, "ingress", [])
	world_open_rule(rule)
	violation := finding(
		"NETWORK_WORLD_INGRESS",
		resource.address,
		"Security-group ingress must not allow traffic from the entire internet",
	)
}

deny contains violation if {
	some resource in active_resource_changes
	resource.type in {"aws_security_group_rule", "aws_vpc_security_group_ingress_rule"}
	object.get(resource.change.after, "type", "ingress") == "ingress"
	world_open_rule(resource.change.after)
	violation := finding(
		"NETWORK_WORLD_INGRESS",
		resource.address,
		"Security-group ingress must not allow traffic from the entire internet",
	)
}

world_open_rule(rule) if {
	some cidr in object.get(rule, "cidr_blocks", [])
	cidr == "0.0.0.0/0"
}

world_open_rule(rule) if {
	some cidr in object.get(rule, "ipv6_cidr_blocks", [])
	cidr == "::/0"
}

world_open_rule(rule) if {
	object.get(rule, "cidr_ipv4", "") == "0.0.0.0/0"
}

world_open_rule(rule) if {
	object.get(rule, "cidr_ipv6", "") == "::/0"
}
