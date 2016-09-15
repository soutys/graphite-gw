#!/usr/bin/env python

import re
import time
import requests
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-p", nargs=1, dest="graphite_prefix",
                    help="Graphite prefix")
parser.add_argument("-g", nargs=1, dest="graphite_gateway",
                    help="Graphite gateway")
parser.add_argument("-c", nargs=1, dest="client_cert",
                    help="Client cert for auth to graphite gateway")
parser.add_argument("-k", nargs=1, dest="client_key",
                    help="Client key for auth to graphite gateway")
args = parser.parse_args()

if not args.graphite_prefix:
    print("Graphite prefix not specified")
    sys.exit(1)

if not args.graphite_gateway:
    print("Graphite gateway not specified")
    sys.exit(1)

if not args.client_cert:
    print("Client cert not specified")
    sys.exit(1)

if not args.client_key:
    print("Client key not specified")
    sys.exit(1)

input = sys.stdin.read()

perfdata_list = re.findall("[^\s\t]+[\s\t]*=[\s\t]*[0-9]+[\.]?[0-9]*",
                           input.split("|")[1].strip())
graphite_prefix = args.graphite_prefix[0]
grapite_gateway = args.graphite_gateway[0]
client_cert = args.client_cert[0]
client_key = args.client_key[0]

perfdata_dict = {}

for metric in perfdata_list:
    label = metric.split("=")[0]
    value = metric.split("=")[1]
    perfdata_dict[re.sub("[^0-9a-zA-Z-_\.]", "_", label)] = value

timestamp = time.time()

graphite_out = ""
for element in sorted(perfdata_dict):
    label = element
    value = perfdata_dict[label]
    graphite_out = graphite_out + "{}{} {} {}\n".format(graphite_prefix, label,
                                                        value, timestamp)

data = {'graphite_out': graphite_out}
requests.post(grapite_gateway,
              cert=(client_cert, client_key), data=data)
