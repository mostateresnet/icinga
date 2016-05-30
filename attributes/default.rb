case node['platform']
  when 'ubuntu'
    case node['platform_version']
      when '14.04'
        default['icinga']['php_path'] = '/etc/php5/apache2/php.ini'
      when '16.04'
        default['icinga']['php_path'] = '/etc/php/7.0/cli/php.ini'
    end
end