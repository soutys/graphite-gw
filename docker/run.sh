#!/usr/bin/env bash

set -xue

docker run \
--volume=/:/rootfs:ro \
--volume=/var/run:/var/run:rw \
--volume=/sys:/sys:ro \
--volume=/var/lib/docker/:/var/lib/docker:ro \
--volume=/dir/with/certs/:/ssl:ro \
-e check_command='/usr/lib/nagios/plugins/check_disk -u bytes -w 10% -c 5% -W 10% -K 5% --exclude-type=tracefs' \
-e check_interval=60 \
-e check_timeout=40 \
-e graphite_url='https://some.graphite-gw.server' \
-e graphite_prefix=some.graphite.prefix. \
-e graphite_gw_client_cert=/ssl/certs/some.host.name.pem \
-e graphite_gw_client_key=/ssl/private_keys/some.host.name.pem \
graphite-gw-nagios-sender
