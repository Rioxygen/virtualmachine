#####*****Instalación de Paqueteria básica****************************#######################
class pckgsextra{
	package { ['git','ant','openvpn' , 'tar', 'telnet', 'java-1.7.0-openjdk-devel', 'java-1.7.0-openjdk', 'nano'] :
    	ensure  => "present",
    }
    file { '/etc/environment':
        ensure  => "file",
        owner => "root",
        group => "root",
        mode  => "644",
        content => "
        LANG=es_MX.utf-8
        LC_ALL=es_MX.utf-8"
    }
    file { '/etc/hosts':
        ensure  => "file",
        owner => "root",
        group => "root",
        mode  => "644",
        content => "
        192.168.67.10  www.wrappergraylogzendlogger.local.com
        192.168.67.10  magentotraining.local.com
        192.168.67.10  magento2training.local.com
        ",
    }
}
######*****Instalación de Compass y Sass*****************####################################
class pckgsass {
    package { ['sass', 'compass']:
      ensure => 'installed',
      provider => 'gem',
    }
}
######*****Instalación de Memcached*****************#####################################
class pckgmemcached {
    class { 'memcached':
        port      => '11211',
        maxconn   => '8192',
        cachesize => '2048',
    }
}

##### ***** NGINX *** ###
class websrv{
    
    class { 'apache':
        default_vhost => true,
        #mpm_module => 'prefork',
    }
    #include ::apache::mod::php
    user { "vagrant":
        ensure     => present,
        gid        => "vagrant",
        groups     => ["apache","vagrant","nginx"],
         # For the user to exist
        require => [Group['nginx'],Group['vagrant'],Group['apache']]
    }
    group {"nginx":
        ensure     => present,
    }
    group {"vagrant":
        ensure     => present,
    }
    # group {"apache":
    #    ensure     => present,
    # }
}
### PHP  ##
class appsrv {
    require websrv
    require yum::repo::remi
    #require yum::repo::epel
    require yum::repo::remi_php70
    # For the user to exist
    package { 'libtidy':
        ensure  => present,
    }
    package { 'libtidy-devel':
        ensure  => present,
    }
    package { 'php-tidy':
        ensure  => present,
    }
    class { 'php::mod_php5':
        inifile => '/etc/httpd/conf.d/php.conf',
        require => Package['httpd']
    }
    
    php::module { [ 'pecl-apcu',
        'pear',
        'pdo',
        'mysqlnd',
        'pgsql',
        'pecl-zip',
        'mbstring',
        'intl',
        'mcrypt',
        'xml',
        'php-devel',
        'pecl-memcached',
        'gd',
        'soap']:
    }
    php::ini { '/etc/php.ini':
        short_open_tag              => 'On',
        memory_limit                => '1G',
        max_execution_time          => '1800',
        asp_tags                    => 'Off',
        date_timezone               => 'America/Mexico_City',
        error_reporting             => 'E_ALL & ~E_DEPRECATED',
        display_errors              => 'On',
        session_save_path           => '/tmp',
        html_errors                 => 'On'
    }
    file { '/var/log/httpd/www-error.log':
        ensure => "file",
        owner  => "apache",
        group  => "apache",
        mode   => "777"
    }
    file { '/var/log/httpd/error.log':
        ensure => "file",
        owner  => "apache",
        group  => "apache",
        mode   => "777"
    }
    #only if you are using php7
    exec { "install_php7":
       path => "/usr/bin/",
       command => "sudo cp /vagrant/php7/php.conf /etc/httpd/conf.d/php.conf"
    }
    
}
##*************Configuracion Core Proeycto*************###
class zendloggergraylog {
    require websrv
    require appsrv
    
}

##*************Magento 1********************************
class magento1 {
    require websrv
    require appsrv

    
}
##*************Magento 12********************************
class magento2 {
    require websrv
    apache::vhost { 'magento2training.local.com':
      port    => '80',
      docroot => '/www/magento2training.local.com',
      options => [
        'Indexes',
        'MultiViews',
      ],
      override => 'All'
    }

}
##*************Magento 12********************************
class cocacola {
    require websrv
    require appsrv
}
#### **** COMPOSER **** ###
class pckgcomposer{
    require appsrv
    #asegura que este instalado el php antes de instalar composer
    #package { 'php':
    #    ensure  => present,
    #}
    class { '::composer':
        require => Package['php'],
        command_name => 'composer',
        target_dir   => '/usr/local/bin',
        auto_update => true
    }
}
######*****Instalación de Xdebug*****************#######################################
class xdebug {

    require appsrv
    package { ['gcc', 'gcc-c++','autoconf','automake'] :
        ensure  => present,
    }->
    exec { "install_xdebug":
       path => "/usr/bin/",
       command => "sudo yum install php-xdebug -y",
       creates => "/usr/lib64/php/modules/xdebug.so"
    }->
    file { "/etc/php.d/15-xdebug.ini":
        ensure  => file,
        # notify  => Service['php-fpm'],
        content => "[xdebug]
            zend_extension=\"/usr/lib64/php/modules/xdebug.so\"
            xdebug.remote_enable = 1
            xdebug.remote_connect_back = 1
            xdebug.collect_params   = 4
            xdebug.collect_vars = on
            xdebug.dump_globals = on
            xdebug.dump.SERVER = REQUEST_URI
            xdebug.show_local_vars = on
            xdebug.cli_color = 1",
    }
}
####**include mysqlserver *##
class mysqlserver {
    class { '::mysql::server':
      package_name            => 'mysql-server',
      root_password           => 'password',
      service_name            => 'mysqld',
      remove_default_accounts => true,
      override_options => {
            mysqld => {
                log-error => '/var/log/mysqld.log',
                pid-file  => '/var/run/mysqld/mysqld.pid'
            },
            mysqld_safe => {
                log-error => '/var/log/mysqld.log'
            },
        }
    }
}
######*****Instalación de Node*****************##############################################
class pckgnode{
    class { 'nodejs':
        repo_url_suffix             => '6.x',
        manage_package_repo         => false,
        nodejs_dev_package_ensure   => 'present',
        npm_package_ensure          => 'present',
    }
}

###
include pckgsextra
include websrv
#include appsrv
#include zendloggergraylog
#include magento1
include magento2
include pckgmemcached
include pckgnode
#include pckgsass
include pckgcomposer
include xdebug
include mysqlserver
#include cocacola
