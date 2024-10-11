return {
    preferred_services = nil,
    instances = {
        attributes = {
            {
                name = "Name",
                value = "Tags[?Key==`Name`].Value | [0]",
            },
            {
                name = "InstanceId",
                value = "InstanceId",
            },
            {
                name = "State",
                value = "State.Name",
            },
            {
                name = "InstanceType",
                value = "InstanceType",
            },
            {
                name = "PrivateIpAddress",
                value = "PrivateIpAddress",
            },
            {
                name = "KeyName",
                value = "KeyName",
            },
        },
    },
    security_groups = {
        attributes = {
            {
                name = "Name",
                value = "Tags[?Key==`Name`].Value | [0]",
            },
            {
                name = "GroupName",
                value = "GroupName",
            },
            {
                name = "GroupId",
                value = "GroupId",
            },
        },
    },
    security_group_rules = {
        attributes = {
            {
                name = "Id",
                value = "SecurityGroupRuleId",
            },
            {
                name = "Outbound",
                value = "IsEgress",
            },
            {
                name = "PortRange",
                value = "FromPort",
            },
            {
                name = "Source",
                value = "not_null(CidrIpv4, CidrIpv6, ReferencedGroupInfo.GroupId)",
            },
            {
                name = "Description",
                value = "Description",
            },
        },
    },
}
