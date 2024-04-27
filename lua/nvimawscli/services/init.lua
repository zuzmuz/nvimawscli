local self = {}

self.names = {
    'ec2',
    'codedeploy',
    's3',
    'rds',
    'iam',
    'vpc',
}

function self.load(service, bufnr, winnr, config)
    require('nvimawscli.self.' .. service).load(bufnr, winnr, config)
end

return self

