#
# Cookbook Name:: icinga
# Recipe:: default
# Author: Seth Thoenen
#
# Copyright (c) 2016 Seth Thoenen, All Rights Reserved.

# Run apt-get update
# This needs to be removed before put into priduction
bash 'run-apt-get-update' do
  code <<-EOH
  apt-get update
  EOH
  action :run
end

# Install Icinga2 base configuration
include_recipe 'icinga::install-icinga2'

# Install IcingaWeb2 base configuraiton
include_recipe 'icinga::install-icingaweb2'

# Configure Icinga2 with hosts, notifications, etc.
include_recipe 'icinga::configure-icinga2'
