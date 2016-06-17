#!/bin/bash
cat << EOF >> /etc/apt/sources.list.d/open-xchange.list

deb http://software.open-xchange.com/products/appsuite/stable/appsuiteui/DebianJessie/ /
deb http://software.open-xchange.com/products/appsuite/stable/backend/DebianJessie/ /

# if you have a valid maintenance subscription, please uncomment the 
# following and add the ldb account data to the url so that the most recent
# packages get installed
# deb http://[CUSTOMERID:PASSWORD]@software.open-xchange.com/products/appsuite/stable/appsuiteui/updates/DebianJessie /
# deb http://[CUSTOMERID:PASSWORD]@software.open-xchange.com/products/appsuite/stable/backend/updates/DebianJessie /
EOF

apt-get update

apt-get install mysql-server open-xchange open-xchange-authentication-database open-xchange-grizzly \
  open-xchange-admin open-xchange-appsuite \
  open-xchange-appsuite-backend open-xchange-appsuite-manifest
  
systemctl start mysql

echo PATH=$PATH:/opt/open-xchange/sbin/ >> ~/.bashrc && . ~/.bashrc

/opt/open-xchange/sbin/initconfigdb --configdb-pass=db_password -a

/opt/open-xchange/sbin/oxinstaller --add-license=YOUR-OX-LICENSE-CODE \
--servername=oxserver --configdb-pass=db_password \
--master-pass=admin_master_password --network-listener-host=localhost --servermemory MAX_MEMORY_FOR_JAVAVM

adjust com.openexchange.mail.loginSource

systemctl restart open-xchange


/opt/open-xchange/sbin/registerserver -n oxserver -A oxadminmaster -P admin_master_password

mkdir /var/opt/filestore
chown open-xchange:open-xchange /var/opt/filestore

/opt/open-xchange/sbin/registerfilestore -A oxadminmaster -P admin_master_password \
-t file:/var/opt/filestore -s 1000000

/opt/open-xchange/sbin/registerdatabase -A oxadminmaster -P admin_master_password \
-n oxdatabase -p db_password -m true

a2enmod proxy proxy_http proxy_balancer expires deflate headers rewrite mime setenvif lbmethod_byrequests

cat << EOF >> /etc/apache2/conf-enabled/proxy_http.conf
<IfModule mod_proxy_http.c>
   ProxyRequests Off
   ProxyStatus On
   # When enabled, this option will pass the Host: line from the incoming request to the proxied host.
   ProxyPreserveHost On
   # Please note that the servlet path to the soap API has changed:
   <Location /webservices>
       # restrict access to the soap provisioning API
       Order Deny,Allow
       Deny from all
       Allow from 127.0.0.1
       # you might add more ip addresses / networks here
       # Allow from 192.168 10 172.16
   </Location>
 
   # The old path is kept for compatibility reasons
   <Location /servlet/axis2/services>
       Order Deny,Allow
       Deny from all
       Allow from 127.0.0.1
   </Location>
   
   # Enable the balancer manager mentioned in
   # http://oxpedia.org/wiki/index.php?title=AppSuite:Running_a_cluster#Updating_a_Cluster
   <IfModule mod_status.c>
     <Location /balancer-manager>
       SetHandler balancer-manager
       Order Deny,Allow
       Deny from all
       Allow from 127.0.0.1
     </Location>
   </IfModule>
   
   <Proxy balancer://oxcluster>
       Order deny,allow
       Allow from all
       # multiple server setups need to have the hostname inserted instead localhost
       BalancerMember http://localhost:8009 timeout=100 smax=0 ttl=60 retry=60 loadfactor=50 route=APP1
       # Enable and maybe add additional hosts running OX here
       # BalancerMember http://oxhost2:8009 timeout=100 smax=0 ttl=60 retry=60 loadfactor=50 route=APP2
      ProxySet stickysession=JSESSIONID|jsessionid scolonpathdelim=On
      SetEnv proxy-initial-not-pooled
      SetEnv proxy-sendchunked
   </Proxy>
   
   # The standalone documentconverter(s) within your setup (if installed)
   # Make sure to restrict access to backends only
   # See: http://httpd.apache.org/docs/$YOUR_VERSION/mod/mod_authz_host.html#allow for more infos
   #<Proxy balancer://oxcluster_docs>
   #    Order Deny,Allow
   #    Deny from all
   #    Allow from backend1IP
   #    BalancerMember http://converter_host:8009 timeout=100 smax=0 ttl=60 retry=60 loadfactor=50 keepalive=On route=APP3
   #    ProxySet stickysession=JSESSIONID|jsessionid scolonpathdelim=On
   #	   SetEnv proxy-initial-not-pooled
   #    SetEnv proxy-sendchunked
   #</Proxy>
   # Define another Proxy Container with different timeout for the sync clients. Microsoft recommends a minimum value of 15 minutes.
   # Setting the value lower than the one defined as com.openexchange.usm.eas.ping.max_heartbeat in eas.properties will lead to connection
   # timeouts for clients.  See http://support.microsoft.com/?kbid=905013 for additional information.
   #
   # NOTE for Apache versions < 2.4:
   # When using a single node system or using BalancerMembers that are assigned to other balancers please add a second hostname for that
   # BalancerMember's IP so Apache can treat it as additional BalancerMember with a different timeout.
   #
   # Example from /etc/hosts: 127.0.0.1	localhost localhost_sync
   #
   # Alternatively select one or more hosts of your cluster to be restricted to handle only eas/usm requests
   <Proxy balancer://eas_oxcluster>
      Order deny,allow
      Allow from all
      # multiple server setups need to have the hostname inserted instead localhost
      BalancerMember http://localhost_sync:8009 timeout=1900 smax=0 ttl=60 retry=60 loadfactor=50 route=APP1
      # Enable and maybe add additional hosts running OX here
      # BalancerMember http://oxhost2:8009 timeout=1900  smax=0 ttl=60 retry=60 loadfactor=50 route=APP2
      ProxySet stickysession=JSESSIONID|jsessionid scolonpathdelim=On
      SetEnv proxy-initial-not-pooled
      SetEnv proxy-sendchunked
   </Proxy>
   
   # When specifying additional mappings via the ProxyPass directive be aware that the first matching rule wins. Overlapping urls of
   # mappings have to be ordered from longest URL to shortest URL.
   # 
   # Example:
   #   ProxyPass /ajax      balancer://oxcluster_with_100s_timeout/ajax
   #   ProxyPass /ajax/test balancer://oxcluster_with_200s_timeout/ajax/test
   #
   # Requests to /ajax/test would have a timeout of 100s instead of 200s 
   #   
   # See:
   # - http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass Ordering ProxyPass Directives
   # - http://httpd.apache.org/docs/current/mod/mod_proxy.html#workers Worker Sharing
   ProxyPass /ajax balancer://oxcluster/ajax
   ProxyPass /appsuite/api balancer://oxcluster/ajax
   ProxyPass /drive balancer://oxcluster/drive
   ProxyPass /infostore balancer://oxcluster/infostore
   ProxyPass /publications balancer://oxcluster/publications
   ProxyPass /realtime balancer://oxcluster/realtime
   ProxyPass /servlet balancer://oxcluster/servlet
   ProxyPass /webservices balancer://oxcluster/webservices

   #ProxyPass /documentconverterws balancer://oxcluster_docs/documentconverterws
 
   ProxyPass /usm-json balancer://eas_oxcluster/usm-json
   ProxyPass /Microsoft-Server-ActiveSync balancer://eas_oxcluster/Microsoft-Server-ActiveSync

</IfModule>
EOF

cat << EOF >>  /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80>
       ServerAdmin webmaster@localhost

       DocumentRoot /var/www/html
       <Directory /var/www/html>
               Options Indexes FollowSymLinks MultiViews
               AllowOverride None
               Order allow,deny
               allow from all
               RedirectMatch ^/$ /appsuite/
       </Directory>

       <Directory /var/www/html/appsuite>
               Options None +SymLinksIfOwnerMatch
               AllowOverride Indexes FileInfo
       </Directory>
</VirtualHost>
EOF

systemctl restart apache2

/opt/open-xchange/sbin/createcontext -A oxadminmaster -P admin_master_password -c 1 \
-u oxadmin -d "Context Admin" -g Admin -s User -p admin_password -L defaultcontext \
-e oxadmin@example.com -q 1024 --access-combination-name=groupware_standard

/opt/open-xchange/sbin/createuser -c 1 -A oxadmin -P admin_password -u testuser \
-d "Test User" -g Test -s User -p secret -e testuser@example.com \
--imaplogin testuser --imapserver 127.0.0.1 --smtpserver 127.0.0.1

tail -f -n200 /var/log/open-xchange/open-xchange.log.0

