# Before applying

`mkdir -p .terraform/tmp`

# OpenWRT initialization

```
uci set network.lan.ipaddr='192.168.0.250'
uci set network.lan.dns='192.168.1.1'
uci set network.lan.gateway='192.168.0.1'
uci commit
reboot
```
Install https://github.com/emonbhuiyan/Redsocks-OpenWRT