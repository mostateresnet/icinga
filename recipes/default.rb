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
