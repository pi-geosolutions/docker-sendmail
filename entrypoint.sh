#!/bin/bash

set -euo pipefail
IP=`hostname -I`

# set hostname conf
echo "127.0.0.1 ${HOSTNAME} localhost localhost.localdomain" >> /etc/hosts
echo "${IP} ${HOSTNAME}" >> /etc/hosts
echo  "${HOSTNAME}" > /etc/hostname

# Tell  sendmail to listen on local network (on local network interface/IP)
# 1. Set local IP instead of loopback
sed -i "s|O DaemonPortOptions=Family=inet,  Name=MTA-v4, Port=smtp, Addr=127.0.0.1|O DaemonPortOptions=Family=inet,  Name=MTA-v4, Port=smtp, Addr=${IP}|" /etc/mail/sendmail.cf
sed -i "s|# FEATURE(\`access_db', , \`skip')dnl|# FEATURE(\`access_db')dnl|" /etc/mail/sendmail.cf
# If not already configured
if [[ -z "$SUBNET" ]]; then
  # try to determine the subnet by extracting this container s subnet
  SUBNET=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | awk -F "." '{print $1"."$2}')
  echo "SUBNET env var was not set. Will try running with SUBNET=$SUBNET"
fi

if grep -q "Connect:${SUBNET}                     RELAY" "/etc/mail/access"; then
    echo "mail access file already configured"
else
    # 2. Tell sendmail to accept local network
    echo "Connect:${SUBNET}                     RELAY" >> /etc/mail/access
    echo "GreetPause:${SUBNET}                  0" >> /etc/mail/access
    echo "ClientRate:${SUBNET}                  0" >> /etc/mail/access
    echo "ClientConn:${SUBNET}                  0" >> /etc/mail/access

    # 3. whitelist if defined -> does not work. It will accept, anyway, all mails From this container's domain
    # if [ -n "${WHITELIST_FROM}" ]; then
    #     WL=$(echo $WHITELIST_FROM | tr "," "\n")
    #     # # blacklist everything else
    #     # echo "From:                  REJECT" >> /etc/mail/access
    #     # Whitelist addresses
    #     for WL_ADDR in $WL; do
    #         echo "From:${WL_ADDR}        OK" >> /etc/mail/access
    #     done
    #     # blacklist everything else
    #     echo "From:                  REJECT" >> /etc/mail/access
    # fi

    # Apply the changes
    cd /etc/mail && make access.db
fi

# run in foreground
# sendmail -bD -v -d
service sendmail restart

# keep running
tail -f /dev/null
