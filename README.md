# Manage aws from inside neovim

This plugin is a wrapper around the aws cli. It allows you to run aws commands from inside neovim.
It assumes you have the aws cli version 2 installed.
This plugin is still in its infancy and only supports a few commands.

## Installation

Use your favorite plugin manager to install this plugin. For example, with lazy

```lua
return {
    'zuzmuz/nvimawscli',
    config = true,
}
```

Add the following to your init.lua if you're using any other way of installing the plugin

```lua
require('nvimawscli').setup()
```

## Usage

You can pass by config to tinker with the default settings. A full list of the default settings will be provided soon

To launch the aws dashboard run the command :Aws

The plugin expects to find the find aws cli tool installed and configured correctly on the machine, it currenlty doesn't provide any method for installing and authenticating with aws.

The first buffer is the menu where a list of available aws services will be shown, preferred services can be set in config to appear on top.

Selecting any service will open a submenu for specific actions to perform in chosen service.

## Services

### Ec2

Currenlt the only supported service.

Supported actions:
- List all available launched instances
- Show general details and statuses about selected instance
- Start/Stop instances
- View basic instance monitoring
- Ssh connection

#### Ssh connect

To connect to ssh the plugin expects to find the ssh private key file in the current directory where nvim is launched. The name of the key is taken from the instance details.

If the key name provided with the instance details is no longer supported (the public key has been manually removed from the instance) the automatic connection will not work.

## And now what?

The plugin currently only supports viewing ec2 instances as well as being able to start/stop and connect to them.
Its goal is to have good coverage of the most common aws commands like elb, s3, rds, codebuild, codedeploy, cloudwatch, etc.
