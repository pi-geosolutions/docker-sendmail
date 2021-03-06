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

# If not already configured
if grep -q "Connect:${SUBNET}                     RELAY" "/etc/mail/access"; then
    echo "mail access file already configured"
else
    # 2. Tell sendmail to accept local network
    echo "Connect:${SUBNET}                     RELAY" >> /etc/mail/access
    echo "GreetPause:${SUBNET}                  0" >> /etc/mail/access
    echo "ClientRate:${SUBNET}                  0" >> /etc/mail/access
    echo "ClientConn:${SUBNET}                  0" >> /etc/mail/access

    # 3. whitelist if defined
    if [ -n "${WHITELIST_FROM}" ]; then
        WL=$(echo $WHITELIST_FROM | tr "," "\n")
        # Whitelist addresses
        for WL_ADDR in $WL; do
            echo "From:${WL_ADDR}        OK" >> /etc/mail/access
        done
        # blacklist everything else
        echo "From:                  REJECT" >> /etc/mail/access
    fi

    # Apply the changes
    cd /etc/mail && make access.db
fi

# run in foreground
# sendmail -bD
service sendmail restart

# keep running
tail -f /dev/null
