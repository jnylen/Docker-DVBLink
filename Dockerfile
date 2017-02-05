# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER jnylen

# Update the repository sources list
RUN apt-get update -q
RUN apt-get upgrade -qy

# Install needed components
RUN apt-get install lsof sysstat wget openssh-server supervisor dbus dbus-x11 consolekit libpolkit-agent-1-0 libpolkit-backend-1-0 policykit-1 python-aptdaemon python-pycurl python3-aptdaemon.pkcompat -qy

#download DVBLink
RUN echo "wget -O dvblink-server-pc-linux-ubuntu-64bit.deb http://download.dvblogic.com/9283649d35acc98ccf4d0c2287cdee62/" > dl.sh
RUN chmod +x dl.sh
RUN ./dl.sh

################## BEGIN INSTALLATION #########################
RUN dpkg -i dvblink-server-pc-linux-ubuntu-64bit.deb
RUN chmod 777 -R /opt/DVBLink/
RUN chmod 777 -R /usr/local/bin/dvblink/

## Share
RUN ln -s /share /usr/local/bin/dvblink/share
RUN mkdir -p /share/licenses
RUN chmod 777 -R /share/licenses
RUN mkdir -p /share/xmltv
RUN chmod 777 -R /share/xmltv
RUN ln -s /share/RecordedTV /recordings
RUN chmod 777 -R /recordings

## Configs
RUN ln -s /config /usr/local/bin/dvblink/config
RUN chmod 777 -R /config

## Logs
RUN touch /usr/local/bin/dvblink/dvblink_reg.log
RUN touch /usr/local/bin/dvblink/dvblink_server.log
RUN touch /usr/local/bin/dvblink/dvblink_webserver.log
RUN touch /usr/local/bin/dvblink/dvblink_install.log
RUN chmod 777 -R /logs
RUN ln /usr/local/bin/dvblink/dvblink_reg.log /logs/dvblink_reg.log
RUN ln /usr/local/bin/dvblink/dvblink_server.log /logs/dvblink_server.log
RUN ln /usr/local/bin/dvblink/dvblink_webserver.log /logs/dvblink_webserver.log
RUN ln /usr/local/bin/dvblink/dvblink_install.log /logs/dvblink_install.log

RUN mkdir -p /var/log/supervisord
RUN mkdir -p /var/run/sshd
RUN mkdir /var/run/dbus
RUN locale-gen en_US.utf8
RUN useradd docker -d /home/docker -g users -G sudo -m
RUN echo docker:test123 | chpasswd
ADD /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
##################### INSTALLATION END #####################

# Expose the default portonly 39876 is nessecary for admin access
EXPOSE 39876 8100

# set Directories
VOLUME ["/config", "/recordings", "/logs", "/share"]

# Startup
ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"]
