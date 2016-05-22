#
# Cookbook Name:: icinga
# Recipe:: default
# Author: Seth Thoenen
#
# Copyright (c) 2016 Seth Thoenen, All Rights Reserved.

# Install Icinga2 base configuration
include_recipe 'icinga::install-icinga2'

# Install IcingaWeb2 base configuraiton
include_recipe 'icinga::install-icingaweb2'

# Configure Icinga2 with hosts, notifications, etc.
include_recipe 'icinga::configure-icinga2'
