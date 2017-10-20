sudo yum install -y ruby;
sudo yum install -y ruby-rdoc ruby-devel;
sudo systemctl stop firewalld;
sudo yum install epel-release -y;
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm;
sudo yum -y install puppet-agent;
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true;
sudo /opt/puppetlabs/bin/puppet module install puppetlabs-mysql --version 5.0.0;
puppet module install puppet-nginx --version 0.5.0;
puppet module install thias-php;
puppet module install puppetlabs-stdlib;
puppet module install puppetlabs-apt;
puppet module install puppetlabs-concat;
puppet module install stahnma-epel;
#causa un error en maquinas no windows 
#lo elimino por eso pero en realidad no servia de nada
#sudo puppet module install chocolatey-chocolatey;
puppet module install treydock-gpg_key;
puppet module install example42-yum;
puppet module install puppetlabs-nodejs;
puppet module install willdurand/composer;
puppet module install thias-memcached;
puppet module install puppet/staging;
puppet module install puppet/archive;
puppet module install puppetlabs/firewall;
#sudo puppet module upgrade puppetlabs-stdlib --force;
puppet module install puppetlabs-ntp --version 6.0.0;
puppet module install puppetlabs-mysql --version 5.1.0 -f;