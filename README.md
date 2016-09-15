# graphite-gw
Graphite SSL gateway

## Overview

Work In Progress

Graphite SSL Gateway is lua/nginx based SSL proxy to graphite using client certificate authentication. Its main purpose is to push metrics to graphite from dynamic number of containers over the insecure network.
![Graphite SSL Gateway Components](https://github.com/RTBHOUSE/graphite-gw/raw/master/docs/img/graphite-gw.png "Graphite SSL Gateway Components")

## Sending output of nagios checks to graphite-gw

Certs being used are from puppet here.

```
/usr/lib/nagios/plugins/check_load -w 38,30,24 -c 80,65,50 | ./nagios/graphite_gw_sender.py \
                                                             -g https://some.graphite.server \
                                                             -p some.graphite.prefix. \
                                                             -c /var/lib/puppet/ssl/certs/some.host.name.pem \
                                                             -k /var/lib/puppet/ssl/private_keys/some.host.name.pem
```
