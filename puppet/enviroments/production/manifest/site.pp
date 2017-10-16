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
        192.168.66.10  www.wrappergraylogzendlogger.local.com
        192.168.66.10  magentotraining.local.com
        192.168.66.10  magento2training.local.com
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
    class { 'nginx': sendfile => off } #moved to hiera.yaml

    user { "nginx":
        ensure     => present,
        gid        => "nginx",
        groups     => ["vagrant","apache"],
         # For the user to exist
        require => [Group['nginx'],Group['vagrant']]
    }
    user { "vagrant":
        ensure     => present,
        gid        => "vagrant",
        groups     => ["vagrant","nginx","apache"],
         # For the user to exist
        require => [Group['nginx'],Group['vagrant'],Group['apache']]
    }
    group {"nginx":
        ensure     => present,
    }
    group {"vagrant":
        ensure     => present,
    }
    group {"apache":
        ensure     => present,
    }
}
### PHP  ##
class appsrv {
    require yum::repo::remi
    #require yum::repo::epel
    require yum::repo::remi_php56
    # For the user to exist
    require websrv
    package { 'libtidy':
        ensure  => present,
    }
    package { 'libtidy-devel':
        ensure  => present,
    }
    package { 'php-tidy':
        ensure  => present,
    }
    class { php::fpm::daemon:
        log_owner => 'nginx',
        log_group => 'nginx',
        log_dir_mode => '0775',
    }
    php::fpm::conf { 'www':
        listen  => '127.0.0.1:9001',
        user    => 'nginx',
    }
    php::module { [ 'pecl-apcu',
        'pear',
        'pdo',
        'mysqlnd',
        'pgsql',
        'pecl-mongo',
        'pecl-sqlite',
        'mbstring',
        'mcrypt',
        'xml',
        'php-devel',
        'pecl-memcached',
        'gd',
        'soap']:
        notify  => Service['php-fpm'],
    }
    php::ini { '/etc/php.ini':
        short_open_tag              => 'On',
        asp_tags                    => 'Off',
        date_timezone               =>'America/Mexico_City',
        error_reporting             => 'E_ALL & ~E_DEPRECATED',
        display_errors              => 'On',
        html_errors                 => 'On',
        notify  => Service['php-fpm'],
    }
    file { '/var/log/php-fpm/www-error.log':
        ensure => "file",
        owner  => "nginx",
        group  => "nginx",
        mode   => "777"
    }
    file { '/var/log/php-fpm/error.log':
        ensure => "file",
        owner  => "nginx",
        group  => "nginx",
        mode   => "777"
    }
}
##*************Configuracion Core Proeycto*************###
class zendloggergraylog {
    require websrv
    require appsrv
    nginx::resource::vhost { 'wrappergraylogzendlogger.local.com':
        www_root            => '/www/wrappergraylogzendlogger.local.com',
        ssl                 => true,
        ssl_cert            => '/vagrant/puppet/certs/server.crt',
        ssl_key             => '/vagrant/puppet/certs/server.key',
        index_files         => [ 'index.php' ],
        use_default_location => true
    }
    nginx::resource::location { "zendloggergraylog_root":
        ensure          => present,
        ssl             => true,
        vhost           => 'wrappergraylogzendlogger.local.com',
        www_root        => '/www/wrappergraylogzendlogger.local.com',
        location        => '~ \.php$',
        index_files     => ['index.php'],
        proxy           => undef,
        fastcgi         => "127.0.0.1:9001",
        fastcgi_script  => undef,
        location_cfg_append => {
            fastcgi_connect_timeout => '5h',
            fastcgi_read_timeout    => '5h',
            fastcgi_send_timeout    => '5h',
            fastcgi_param    => "APPLICATION_ENV 'development'"
        }
    }
    
}
#### **** COMPOSER **** ###
class pckgcomposer{
    require appsrv
    #asegura que este instalado el php antes de instalar composer
    package { 'php':
        ensure  => present,
    }
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
        notify  => Service['php-fpm'],
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
include appsrv
include zendloggergraylog
include pckgmemcached
include pckgnode
#include pckgsass
include pckgcomposer
include xdebug
