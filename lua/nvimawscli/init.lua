local dashboard = {}

dashboard.config = {
    prefered_services = {
        "ec2",
        "codedeply",
        "s3",
        "rds",
        "iam",
        "vpc",
    },
}

function dashboard.setup(config)
    print("Setting up dashboard")
    dashboard.config = config
end

function dashboard.launch()

    local menu = require("nvimawscli.menu")
    menu:load(dashboard.config)

end

return dashboard
