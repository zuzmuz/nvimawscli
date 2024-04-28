local self = {}

self.names = {
    'ec2',
    'codedeploy',
    's3',
    'rds',
    'iam',
    'vpc',
}

function self.load(service_name, bufnr, winnr, config)
    local status, service = pcall(require, 'nvimawscli.services.' .. service_name)

    if status then
        service.load(bufnr, winnr, config)
    else
        print("Service not implemented yet: " .. service_name)
    end
end

return self

