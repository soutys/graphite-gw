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
                                        -g https://some.graphite-gw.server \
                                        -p some.graphite.prefix. \
                                        -c /var/lib/puppet/ssl/certs/some.host.name.pem \
                                        -k /var/lib/puppet/ssl/private_keys/some.host.name.pem
```

## Sending metrics using curl

### single line
```
curl -v --cert /var/lib/puppet/ssl/certs/some.host.name.pem \
        --key /var/lib/puppet/ssl/private_keys/some.host.name.pem \
        --data 'graphite_out=some.graphite.prefix.some_host_name.load.oneminute 4.02 1463739596'
        -data-binary @data.txt \
        'https://some.graphite-gw.server/'
```

### multiple lines

```
curl -v --cert /var/lib/puppet/ssl/certs/some.host.name.pem \
        --key /var/lib/puppet/ssl/private_keys/some.host.name.pem \
        --data-binary @data.txt \
        'https://some.graphite-gw.server/'
```

where data.txt might be something like this (metrics from pcp):

```
some.graphite.prefix.some_host_name.network.tcpconn.established 6.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.syn_sent 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.syn_recv 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.fin_wait1 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.fin_wait2 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.time_wait 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.close 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.close_wait 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.last_ack 0.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.listen 3.0 1464017975
some.graphite.prefix.some_host_name.network.tcpconn.closing 0.0 1464017975
some.graphite.prefix.some_host_name.network.udp.indatagrams 2593078.0 1464017975
some.graphite.prefix.some_host_name.network.udp.noports 1.0 1464017975
some.graphite.prefix.some_host_name.network.udp.inerrors 0.0 1464017975
some.graphite.prefix.some_host_name.network.udp.outdatagrams 2596401.0 1464017975
some.graphite.prefix.some_host_name.network.udp.recvbuferrors 0.0 1464017975
some.graphite.prefix.some_host_name.network.udp.sndbuferrors 0.0 1464017975
some.graphite.prefix.some_host_name.network.udp.incsumerrors 0.0 1464017975
some.graphite.prefix.some_host_name.swap.pagesin 0.0 1464017975
some.graphite.prefix.some_host_name.swap.pagesout 0.0 1464017975
some.graphite.prefix.some_host_name.swap.free 1073737728.0 1464017975
some.graphite.prefix.some_host_name.swap.length 1073737728.0 1464017975
some.graphite.prefix.some_host_name.swap.used 0.0 1464017975
some.graphite.prefix.some_host_name.swapdev.free.__dev_dm-0 1048572.0 1464017975
some.graphite.prefix.some_host_name.vfs.files.count 5232.0 1464017975
some.graphite.prefix.some_host_name.vfs.files.free 0.0 1464017975
some.graphite.prefix.some_host_name.vfs.files.max 13160628.0 1464017975
some.graphite.prefix.some_host_name.vfs.inodes.count 42450.0 1464017975
some.graphite.prefix.some_host_name.vfs.inodes.free 429.0 1464017975
some.graphite.prefix.some_host_name.vfs.dentry.count 127026.0 1464017975
some.graphite.prefix.some_host_name.vfs.dentry.free 106945.0 1464017975
```
