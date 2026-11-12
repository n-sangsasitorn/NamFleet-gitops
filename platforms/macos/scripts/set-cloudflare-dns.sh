#!/bin/bash
#
# Point every network service (Wi-Fi, Ethernet, USB adapters, ...) at
# Cloudflare DNS. Run automatically by the
# "macOS - DNS resolves through Cloudflare (1.1.1.1)" policy when it fails.

DNS_SERVERS=(1.1.1.1 1.0.0.1)
status=0

# First line of output is a header; disabled services are prefixed with "*".
while IFS= read -r service; do
  service="${service#\*}"
  [ -z "$service" ] && continue
  echo "Setting DNS for \"$service\" to ${DNS_SERVERS[*]}"
  if ! /usr/sbin/networksetup -setdnsservers "$service" "${DNS_SERVERS[@]}"; then
    echo "  failed to set DNS for \"$service\"" >&2
    status=1
  fi
done < <(/usr/sbin/networksetup -listallnetworkservices | tail -n +2)

# Flush the DNS cache so the change takes effect immediately.
/usr/bin/dscacheutil -flushcache
/usr/bin/killall -HUP mDNSResponder 2>/dev/null

exit $status
