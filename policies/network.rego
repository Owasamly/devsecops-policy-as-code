package terraform.security


deny contains msg if {

    resource := input.resource_changes[_]


    resource.type == "aws_security_group"


    rule := resource.change.after.ingress[_]


    rule.cidr_blocks[_] == "0.0.0.0/0"


    msg := sprintf(
        "Security group %s allows unrestricted internet access",
        [resource.change.after.name]
    )

}