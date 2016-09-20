FROM ubuntu:16.04
RUN apt-get -y update && apt-get -y install nagios-plugin-check-multi nagios-plugins-basic nagios-plugins-common nagios-plugins-contrib nagios-plugins-standard python-requests
COPY nagios_pluging_runner.bash /usr/local/bin/
RUN chmod +x /usr/local/bin/nagios_pluging_runner.bash
ADD https://raw.githubusercontent.com/RTBHOUSE/graphite-gw/master/nagios/graphite_gw_sender.py /usr/local/bin/
RUN chmod +x /usr/local/bin/graphite_gw_sender.py 
CMD ["/usr/local/bin/nagios_pluging_runner.bash"]
