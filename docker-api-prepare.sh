#!/bin/sh
# Prepare some local folder structure to ensure volume sharing with containers
mkdir -p -m 700 ~/api/data ~/api/log/apache2 ~/api/screen ~/api/security/tls/letsencrypt/etc ~/api/security/tls/letsencrypt/var ~/api/security/ca ~/api/templates
chmod -R 755 ~/api/templates ~/api/security/tls ~/api/log
chown -R www-data:www-data ~/api/security/tls ~/api/log ~/api/templates

echo "$(tput setaf 10)DONE$(tput sgr0) File structure checked"
# Make sure that some classic DNS are use to make Docker's DNS behave as expected
# See https://github.com/michaelgrosner/tribeca/issues/184
# This issue was noted Closed, but is actually not fixed as per mid-2018
export DAEMON_CONF=/etc/docker/daemon.json
if test -n "$(find /var/lib/dhcp/ -maxdepth 1 -name 'dhclient*.leases' -print -quit)" ; then
 export DNS_SERVER_REAL_FIRST=`cat /var/lib/dhcp/dhclient*.leases | grep dhcp-server-identifier | grep -m1 -Eow "([^ ]*);$" | sed s'/.$//'`
 if grep -q $DNS_SERVER_REAL_FIRST $DAEMON_CONF ;  then
   echo "$(tput setaf 11)TODO$(tput sgr0) $DNS_SERVER_REAL_FIRST DNS Looks like already set in $DAEMON_CONF. Please make sure it is set as first DNS server in the dns property." 
 else
  #So, let's fix it
  if [ -s $DAEMON_CONF ]; then
   echo "$(tput setaf 11)TODO$(tput sgr0) Please add manually the DNS server $DNS_SERVER_REAL_FIRST value to the file $DAEMON_CONF in the dns property at first position of the JSON array."
  else
   echo "{ \"dns\": [\"$DNS_SERVER_REAL_FIRST\", \"8.8.8.8\", \"9.9.9.9\"] }" > $DAEMON_CONF
   echo "$(tput setaf 10)DONE$(tput sgr0) Creating $DAEMON_CONF file with a fixed DNS Server $DNS_SERVER_REAL_FIRST to prevent Docker DNS issues EAI_RETRY"
  fi
 fi
else
 echo "$(tput setaf 11)WARN$(tput sgr0) Not able to update $DAEMON_CONF as your DHCP configuration is currently not supported by this script. If Docker generate some DNS issues EAI_RETRY, please open an issue with details of your distribution & environment."
fi
cp utils/api-up.sh ~/api/
cp utils/api-down.sh ~/api/
cp -n docker-compose.yml ~/api/
echo "$(tput setaf 10)DONE$(tput sgr0) File utils copied"

