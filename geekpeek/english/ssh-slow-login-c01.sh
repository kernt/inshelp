# GeekPeek.Net scripts - SSH Slow Login script
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. This script disabled UseDNS
# option and GSSAPIAuthentication in /etc/ssh/sshd_config file. SSH is restarted due to configuration changes.
#
# CODE:
/bin/sed -ie "s/#UseDNS\ yes/UseDNS\ no/g" /etc/ssh/sshd_config
/bin/sed -ie "s/#UseDNS\ no/UseDNS\ no/g" /etc/ssh/sshd_config
/bin/sed -ie "s/UseDNS\ yes/UseDNS\ no/g" /etc/ssh/sshd_config
/bin/sed -ie "s/#GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g" /etc/ssh/sshd_config
/bin/sed -ie "s/#GSSAPIAuthentication\ no/GSSAPIAuthentication\ no/g" /etc/ssh/sshd_config
/bin/sed -ie "s/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g" /etc/ssh/sshd_config
/etc/init.d/sshd restart
