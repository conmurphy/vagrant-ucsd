# Cisco UCS Director Vagrant Provider Plugin - Proof of Concept

This is a Vagrant plugin that adds a Cisco UCS Director provider to Vagrant. It allows Vagrant to communicate with UCSD and have it provision machines in a private environment. 

This plugin is currently a Proof of Concept and has been developed and tested against Cisco UCS Director 6.0 and Vagrant 1.2+

![alt tag](https://github.com/conmurphy/vagrant-ucsd/blob/master/images/overview.png)

Table of Contents
=================

   * [Cisco UCS Director Vagrant Provider Plugin - Proof of Concept](#cisco-ucs-director-vagrant-provider-plugin---proof-of-concept)
      * [Features](#features)
      * [Usage](#usage)
      * [Vagrantfile structure](#vagrantfile-structure)
      * [Installation](#installation)
      * [Box Format](#box-format)
      * [Configuration](#configuration)
      * [Synced Folders](#synced-folders)
      * [Development](#development)

## Features

* Boot instances through UCSD
* SSH into the instances
* Provision the instances with any built-in Vagrant provisioner
* Minimal synced folder support via `rsync`

## Usage

After installing the plugin use the `vagrant up` command an specify the `ucsd`  provider.

```
$ vagrant up --provider=ucsd
...
```

The following additional plugin commands have been provided:

* `vagrant ucsd init` - Create a template Vagrantfile and populate with your own configuration
* `vagrant ucsd catalog` - Return a list of the current available catalog 

## Vagrantfile structure 

You can either manually create a Vagrantfile that looks like the following, filling in
your information where necessary, or run the `vagrant ucsd init` command to have an empty Vagrantfile created for you.

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

	config.vm.box = 'ucsd'
 
	
   config.vm.provider :ucsd do |ucsd|
    ucsd.access_key = ''
    ucsd.host_ip = ''
    ucsd.catalog_item = ''
    ucsd.vdc = ''
    ucsd.vm_name = ''
    ucsd.username = ''
   end
  
  	config.vm.synced_folder '.', '/opt/my_files/', type: 'rsync'

end
```

## Installation

## Box Format

## Configuration

This provider exposes quite a few provider-specific configuration options:

* `access_key` - The access key for accessing the Cisco UCS Director API
* `username` - The username for accessing UCSD 
* `host_ip` - The host IP address of UCS Director
* `catalog_item` - The catalog item/template from which you wish to deploy a new VM
* `vdc` - The name of the VDC in to which the VM will be deployed
* `vm_name` - The name you would like to assign to the deployed VM


## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the UCSD provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

See [Vagrant Synced folders: rsync](https://docs.vagrantup.com/v2/synced-folders/rsync.html)

## Development

To work on the UCSD plugin, clone this repository then run the following commands to build and install the plugin.

```
$ gem build vagrant-ucsd.gemspec
$ vagrant plugin install ./vagrant-ucsd-0.1.0.gem
```

To uninstall the plugin run `vagrant plugin uninstall vagrant-ucsd`


WARNING:

These scripts are meant for educational/proof of concept purposes only. Any use of these scripts and tools is at your own risk. There is no guarantee that they have been through thorough testing in a comparable environment and we are not responsible for any damage or data loss incurred with their use.
