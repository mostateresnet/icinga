#
# Cookbook Name:: icinga
# Recipe:: default
# Author: Seth Thoenen
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Run apt-get update
bash 'run-apt-get-update' do
  code <<-EOH
  apt-get update
  EOH
  action :run
end


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
  not_if { File.exist?('/etc/apt/sources.list.d/formorer-icinga-trusty.list') }
end

# Install icinga2 package
apt_package 'icinga2' do
  action :install
end

# Install MySQL Server
apt_package 'mysql-server' do
  action :install
end

# Install MySQL Client
apt_package 'mysql-client' do
  action :install
end

# Install icinga2 MySQL package
apt_package 'icinga2-ido-mysql' do
  action :install
  notifies :create, 'template[/tmp/icinga-sql.sql]', :immediately
end

# place .sql file on local machiene
template '/tmp/icinga-sql.sql' do
  action :nothing
  source 'icinga-sql.erb'
  owner 'root'
  mode '0755'
  notifies :run, 'bash[execute-icinga-sql]', :immediately
end

# Execute SQL command to create icinga database
bash 'execute-icinga-sql' do
  action :nothing
  code <<-EOH
  mysql -u root < /tmp/icinga-sql.sql
  EOH
  notifies :run, 'bash[create-icinga-database-schema]', :immediately
end

# Configure icinga
bash 'create-icinga-database-schema' do
  code <<-EOH
  mysql -u root icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
  EOH
  action :nothing
  notifies :run, 'bash[enable-ido-mysql]', :immediately
end

# enable ido sql feature
bash 'enable-ido-mysql' do
  code <<-EOH
  icinga2 feature enable ido-mysql
  EOH
  action :nothing
  notifies :run, 'bash[restart-icinga2-service]'
end

# restart icinga service
bash 'restart-icinga2-service' do
  code <<-EOH
  service icinga2 restart
  EOH
  action :nothing
end

# install apache
apt_package 'apache2' do
  action :install
  notifies :run, 'bash[enable-ssl]'
end

# Enable SSL
bash 'enable-ssl' do
  code <<-EOH
  a2enmod ssl
  EOH
  action :nothing
  notifies :run, 'bash[enable-firewall-rules]'
end


# enable http and https traffic
bash 'enable-firewall-rules' do
  code <<-EOH
  iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
  EOH
  action :nothing
  notifies :run, 'bash[enable-external-command-pipe]'
end

# Set up external command pipe
bash 'enable-external-command-pipe' do
  code <<-EOH
  icinga2 feature enable command
  service icinga2 restart
  usermod -a -G nagios www-data
  EOH
  action :nothing
end

# Install icingaweb2 package
apt_package 'icingaweb2' do
  action :install
  notifies :run, 'bash[add-icingaweb2-to-system-group]'
end

# Add icingaweb2 user to system group
bash 'add-icingaweb2-to-system-group' do
  code <<-EOH
  addgroup --system icingaweb2
  usermod -a -G icingaweb2 www-data
  service apache2 restart
  EOH
  action :nothing
end

# place .sql file to configure icingaweb2 on local machine
template '/tmp/icingaweb2-sql.sql' do
  action :create
  source 'icingaweb2-sql.erb'
  owner 'root'
  mode '0755'
  notifies :run, 'bash[execute-icingaweb2-sql]', :immediately
end

# Execute SQL command to create icingaweb2 database
bash 'execute-icingaweb2-sql' do
  action :nothing
  code <<-EOH
  mysql -u root < /tmp/icingaweb2-sql.sql
  EOH
  notifies :run, 'bash[create-icingaweb2-database-schema]', :immediately
end

# Configure icingaweb2
bash 'create-icingaweb2-database-schema' do
  code <<-EOH
  mysql -u root icingaweb2 < /usr/share/icingaweb2/etc/schema/mysql.schema.sql
  EOH
  action :nothing
end

# place .sql file to create icingaweb2 administrator account on local machine
template '/tmp/icingaweb2-add-admin-sql.sql' do
  source 'icingaweb2-add-admin-sql.erb'
  owner 'root'
  mode '0755'
  action :create
  notifies :run, 'bash[execute-icingaweb2-add-admin-sql]'
end

# Execute SQL command to create icingaweb2 administrator account
bash 'execute-icingaweb2-add-admin-sql' do
  code <<-EOH
  mysql -u root icingaweb2 < /tmp/icingaweb2-add-admin-sql.sql
  EOH
  action :nothing
end

# Place .ini file at /etc/icingaweb2/resources.ini
template '/etc/icingaweb2/resources.ini' do
  source 'icingaweb2-resources-ini.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Place .ini file at /etc/icingaweb2/config.ini
template '/etc/icingaweb2/config.ini' do
  source 'icingaweb2-config-ini.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Place .ini file at /etc/icingaweb2/authentication.ini
template '/etc/icingaweb2/authentication.ini' do
  source 'icingaweb2-authentication-ini.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Place .ini file at /etc/icingaweb2/roles.ini
template '/etc/icingaweb2/roles.ini' do
  source 'icingaweb2-roles-ini.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Create directory at /etc/icingaweb2/monitoring
directory '/etc/icingaweb2/modules/monitoring/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


# Place .ini file at /etc/icingaweb2/monitoring/config.ini
template '/etc/icingaweb2/modules/monitoring/config.ini' do
  source 'icingaweb2-monitoring-config-ini.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Place .ini file at /etc/icingaweb2/monitoring/backends.ini
template '/etc/icingaweb2/modules/monitoring/backends.ini' do
  source 'icingaweb2-monitoring-backends-ini.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Place .ini file at /etc/icingaweb2/monitoring/commandtransports.ini
template '/etc/icingaweb2/modules/monitoring/commandtransports.ini' do
  source 'icingaweb2-monitoring-commandtransport-ini.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Create ssl directory
directory '/etc/apache2/ssl' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Place SSL .crt on local machine
template '/etc/apache2/ssl/apache.crt' do
  source 'apache-crt.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Place SSL .key on local machine
template '/etc/apache2/ssl/apache.key' do
  source 'apache-key.erb'
  owner 'root'
  mode '0755'
  action :create
end

# Assign the server's hostname to a variable
hostname = Socket.gethostname

# Place default.conf on local machine
template '/etc/apache2/sites-available/000-default.conf' do
  source 'apache-default-conf.erb'
  owner 'root'
  mode '0755'
  action :create
  variables({
    :host_name => hostname
  })
end

# Place default-ssl.conf on local machine
template '/etc/apache2/sites-available/default-ssl.conf' do
  source 'apache-default-ssl.erb'
  owner 'root'
  mode '0755'
  action :create
  variables({
    :host_name => hostname
  })
  notifies :run, 'bash[enable-ssl-configuration]'
end

# Enable SSL Configuration
bash 'enable-ssl-configuration' do
  code <<-EOH
  a2ensite default-ssl.conf
  service apache2 restart
  EOH
  action :nothing
end

# Update php.ini
template '/etc/php5/apache2/php.ini' do
  source 'php-ini.erb'
  owner 'root'
  mode '0755'
  action :create
  variables({
    :timezone => 'America/Chicago'
  })
end

