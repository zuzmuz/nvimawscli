local utils = require('nvimawscli.utils.buffer')
local command = require('nvimawscli.commands.s3')
local table_renderer = require('nvimawscli.utils.tables')
local config = require('nvimawscli.config')
local bucket_actions = require('nvimawscli.services.s3.actions')
local ui = require('nvimawscli.utils.ui')
local itertools = require('nvimawscli.utils.itertools')
---@class S3Bucket
local M = {}
