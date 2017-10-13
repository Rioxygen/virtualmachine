sudo yum install -y ruby;
sudo yum install -y ruby-rdoc ruby-devel;
sudo systemctl stop firewalld;
sudo yum install epel-release -y;
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm;
sudo yum -y install puppet-agent;
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true;
sudo /opt/puppetlabs/bin/puppet module install puppetlabs-mysql --version 5.0.0;