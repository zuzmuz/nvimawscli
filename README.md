# Manage aws from inside neovim

This plugin is a wrapper around the aws cli. It allows you to run aws commands from inside neovim.
It assumes you have the aws cli version 2 installed.
This plugin is still in its infancy and only supports a few commands.

## Installation

Use your favorite plugin manager to install this plugin. For example, with lazy

```lua
  'zuzmuz/nvimawscli',
```

## Usage

Add the following to your init.lua

```lua
require('nvimawscli').setup()
```

You can pass by config to tinker with the default settings. A full list of the default settings will be provided soon

To launch the aws dashboard run the command :AWS

## And now what?

The plugin currently only supports viewing ec2 instances as well as being able to start/stop and connect to them.
Its goal is to have good coverage of the most common aws commands like elb, s3, rds, codebuild, codedeploy, cloudwatch, etc.
