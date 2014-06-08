#!/bin/bash
# source http://www.panticz.de/install_mx

# helpfull but not completely working.
# ToDo
# configure antivirus
# configure antispam
# configure secure connections
 
#
# configure timezone and locale
#
# dpkg-reconfigure tzdata
# locale-gen de_DE
 
# install Postfix
http://www.panticz.de/Install-Postfix
 
# install Dovecot
http://www.panticz.de/Install-Dovecot
 
#
# SASL
#
# install
apt-get install -y sasl2-bin
 
# post-configure
cp /etc/default/saslauthd /etc/default/saslauthd.$(date -I)
sed -i 's|START=no|START=yes|g' /etc/default/saslauthd
#sed -i 's|OPTIONS="-c -m /var/run/saslauthd"|OPTIONS="-c -m /var/spool/postfix/var/run/saslauthd"|g' /etc/default/saslauthd
 
cat <<EOF> /etc/postfix/sasl/smtpd.conf
pwcheck_method: saslauthd
mech_list: PLAIN LOGIN
EOF
 
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'
postconf -e 'broken_sasl_auth_clients = yes'
 
# add user
adduser postfix sasl
 
# restart
/etc/init.d/saslauthd restart
/etc/init.d/postfix restart
 
 
#
# MAILDROP
#
# install
apt-get install -y maildrop
 
# post-configure
cp /etc/maildroprc /etc/maildroprc.$(date -I)
sed -i 's|#DEFAULT="$HOME/Maildir"|DEFAULT="$HOME/Maildir"|g' /etc/maildroprc
 
postconf -e 'mailbox_command = /usr/bin/maildrop -d ${USER}'
 
# restart
/etc/init.d/postfix restart
 
 
#
# FETCHMAIL 
#
# insall
apt-get install -y fetchmail
 
# post-configure
cp /etc/default/fetchmail /etc/default/fetchmail.$(date -I)
sed -i 's|START_DAEMON=no|START_DAEMON=yes|g' /etc/default/fetchmail
 
cp /etc/fetchmailrc /etc/fetchmailrc.$(date -I)
# cp /tmp/etc/fetchmailrc /etc/
cat <<EOF> /etc/fetchmailrc
set postmaster root
set daemon 120
set syslog
 
poll pop3.example.com protocol POP3
user username@example.com password USER_PASSWORD is USER_NAME
EOF
chown fetchmail /etc/fetchmailrc
 
# restart
/etc/init.d/fetchmail restart
 
 
 
 
#
# amavisd-new
#
apt-get install -y amavisd-new spamassassin clamav clamav-daemon unzip libnet-ph-perl libnet-snpp-perl libnet-telnet-perl nomarch lzop unrar-free ripole unrar-free bzip2
cp /etc/default/spamassassin /etc/default/spamassassin.$(date -I)
##sed -i 's|ENABLED=no|ENABLED=yes|g' /etc/default/spamassassin             # debian 6
sed -i 's|ENABLED=0|ENABLED=1|g' /etc/default/spamassassin   # debian 7
 
# configure
cp /etc/amavis/conf.d/15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode.$(date -I)
sed -i 's|#@bypass|@bypass|g' /etc/amavis/conf.d/15-content_filter_mode
sed -i 's|#   \\%bypass|   \\%bypass|g' /etc/amavis/conf.d/15-content_filter_mode
#@bypass_virus_checks_maps
#   \%bypass_virus_checks
#@bypass_spam_checks_maps
#   \%bypass_spam_checks
 
#?# cp /etc/amavis/conf.d/20-debian_defaults /etc/amavis/conf.d/20-debian_defaults.$(date -I)
 
# update clamav virus definitions
freshclam
 
adduser clamav amavis
/etc/init.d/amavis restart
 
#?# cp /etc/clamav/clamd.conf /etc/clamav/clamd.conf.$(date -I)
/etc/init.d/clamav-daemon restart
 
# cp /etc/clamav/freshclam.conf /etc/clamav/freshclam.conf.$(date -I)
 
/etc/init.d/clamav-freshclam restart
 
postconf -e 'content_filter = amavis:[127.0.0.1]:10024'
postconf -e 'receive_override_options = no_address_mappings'
 
cp /etc/postfix/master.cf /etc/postfix/master.cf.$(date -I)
 
cat <<EOF>> /etc/postfix/master.cf
amavis unix - - - - 2 smtp
        -o smtp_data_done_timeout=1200
        -o smtp_send_xforward_command=yes
 
127.0.0.1:10025 inet n - - - - smtpd
        -o content_filter=
        -o local_recipient_maps=
        -o relay_recipient_maps=
        -o smtpd_restriction_classes=
        -o smtpd_client_restrictions=
        -o smtpd_helo_restrictions=
        -o smtpd_sender_restrictions=
        -o smtpd_recipient_restrictions=permit_mynetworks,reject
        -o mynetworks=127.0.0.0/8
        -o strict_rfc821_envelopes=yes
        -o receive_override_options=no_unknown_recipient_checks,no_header_body_checks
#        -o smtpd_bind_address=127.0.0.1
EOF
 
/etc/init.d/postfix restart
 
 
apt-get install -y razor pyzor
#??dcc-client
 
cp /etc/spamassassin/local.cf /etc/spamassassin/local.cf.$(date -I)
 
sed -i 's|# rewrite_header Subject|rewrite_header Subject|g' /etc/spamassassin/local.cf
sed -i 's|# use_bayes 1|use_bayes 1|g' /etc/spamassassin/local.cf
sed -i 's|# bayes_auto_learn 1|bayes_auto_learn 1|g' /etc/spamassassin/local.cf
 
cat <<EOF>> /etc/spamassassin/local.cf
#pyzor
use_pyzor 1
pyzor_path /usr/bin/pyzor
pyzor_add_header 1
 
#razor
use_razor2 1
razor_config /etc/razor/razor-agent.conf
 
#bayes
#use_bayes_rules 1
EOF
 
 
#
# COURIER (only if your dont use dovecot)
#
# pre-configure
debconf-set-selections <<\EOF
courier-base courier-base/webadmin-configmode boolean false
EOF
 
# install
apt-get install -y courier-imap
 
# create maildirs
maildirmake /etc/skel/Maildir
maildirmake /etc/skel/Maildir/.Drafts
maildirmake /etc/skel/Maildir/.Sent
maildirmake /etc/skel/Maildir/.Trash
maildirmake /etc/skel/Maildir/.Templates
maildirmake /etc/skel/Maildir/.SPAM
 
# restart
/etc/init.d/courier-imap restart
 
 
#
# TEST
# 
# install
#apt-get install -y mailx
 
# send test mail
#mail -s "test_$(date)" YOUR_EMAIL < /etc/hosts
echo "This is a test message from ${USER}@${HOSTNAME} at $(date)" | sendmail YOUR_EMAIL
 
 
# view found spam
grep SPAM /var/log/syslog
 
 
#
# LINKS
#
http://www.ubuntu.com/products/whatisubuntu/serveredition/features/mailserver - Ubuntu Features Mail server 
http://www.howtoforge.de/howto/der-perfekte-server-ubuntu-hardy-heron-ubuntu-804-lts-server/
http://holl.co.at/howto-email/
# mailq
http://www.huschi.net/4_277_de.html
# fetchmail
http://wiki.ubuntuusers.de/Fetchmail
# sasl
http://wiki.ubuntuusers.de/Postfix/Erweiterte_Konfiguration
# postfix
http://wiki.ubuntuusers.de/Postfix
https://help.ubuntu.com/community/Postfix
http://www.postfix.org/postconf.5.html
# amavisd
http://www.howtoforge.de/howto/amavisd-new-in-postfix-zur-spam-und-virus-uberprufung-integrieren/
 
 
 
 
# test
vi /etc/hostname 
vi mailname 
vi /etc/amavis/conf.d/05-node_id
