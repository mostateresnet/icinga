#
# Cookbook Name:: icinga
# Recipe:: default
# Author: Seth Thoenen
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install software-propert9es-common so we can use add-apt-repository later
apt_package 'software-properties-common' do
  action :install
end

# Configure apt-get to find icinga packages
bash 'add icinga repository' do
  code <<-EOH
  add-apt-repository ppa:formorer/icinga
  apt-get update
  EOH
  action :run
  not_if { File.exist?('/etc/apt/sources.list.d/formorer-icinga-trusty.list')}
end

# Install icinga2 package
apt_package 'icinga2' do
  action :install
end
