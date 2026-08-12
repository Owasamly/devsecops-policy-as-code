package terraform.security

import rego.v1

active_resource_changes := [resource |
	some resource in object.get(input, "resource_changes", [])
	resource.change.actions != ["delete"]
]

finding(code, resource, message) := {
	"code": code,
	"message": message,
	"resource": resource,
}

linked_resources(bucket_address, resource_type) := [change |
	some configured in object.get(object.get(object.get(input, "configuration", {}), "root_module", {}), "resources", [])
	configured.type == resource_type
	some reference in object.get(object.get(object.get(configured, "expressions", {}), "bucket", {}), "references", [])
	reference == bucket_address
	some change in active_resource_changes
	change.address == configured.address
]
