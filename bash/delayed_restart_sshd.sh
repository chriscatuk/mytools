#!/bin/bash
# Restart SSH after IPv6 address is defined on Raspberry Pi
# Address a race condition where sshd starts before IPv6 is ready for binding to a specific address
# To be placed in /etc/network/if-up.d/010restartsshd

# Run only all interface are started
if [ "$IFACE" != "--all" ]; then
  /usr/bin/logger "[delayed_restart_sshd] not running for $IFACE" -p user.debug -s
  exit 0
fi

# Wait to ensure the IPv6 is set
# sleep 120

/usr/bin/logger "[delayed_restart_sshd] Restarting sshd to address race condition now that $IFACE is up"

# Restart sshd service
/bin/systemctl restart sshd
if [ "$?" -ne 0 ]; then
   /usr/bin/logger "[delayed_restart_sshd][Error] Could not restart sshd. Aborting" -p user.err
   exit 1
else
   /usr/bin/logger "[delayed_restart_sshd] Restarted sshd service successfully" 
fi

