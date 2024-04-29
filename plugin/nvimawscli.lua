vim.api.nvim_create_user_command('NvimAwsCli', function (opts)
    require('nvimawscli').launch()
end, {})

vim.api.nvim_create_user_command('NvimAwsCliMenu', function (opts)
    require('nvimawscli.menu').hide()
end, {})
