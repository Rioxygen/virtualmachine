
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
        192.168.100.11  www.proyecto.local.com
        192.168.100.11  www.coreproyecto.local.com
        192.168.100.11  www.maqueta.local.com
        ",
    }
}

include pckgsextra
