vim.api.nvim_create_user_command('NvimAwsCli', function (opts)
    require('nvimawscli').launch()
end, {})
