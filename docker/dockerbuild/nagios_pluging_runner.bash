#!/usr/bin/env bash
set -xue

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

while :; do
    (timeout --kill-after=0 "$check_timeout" bash -c "$check_command" | /usr/local/bin/graphite_gw_sender.py \
                                        -g "$graphite_url" \
                                        -p "$graphite_prefix" \
                                        -c "$graphite_gw_client_cert" \
                                        -k "$graphite_gw_client_key")& 
    sleep "$check_interval";
done
