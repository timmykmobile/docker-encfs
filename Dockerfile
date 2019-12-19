####################
# BASE IMAGE
####################
FROM ubuntu:latest

MAINTAINER timmykmobile

# Update Software repository
RUN apt-get update

####################
# INSTALLATIONS
####################
RUN apt-get install -y encfs && \
    rm -rf /var/lib/apt/lists/*

# add local files
ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh  && \
    chmod a+x /usr/bin/* && \
    groupmod -g 1000 users && \
	useradd -u 911 -U -d / -s /bin/false abc && \
	usermod -G users abc && \
    apt-get clean autoclean && \
    apt-get autoremove -y

####################
# ENVIRONMENT VARIABLES
####################
# Encryption
ENV REVERSE "no" # set the default variable

####################
# VOLUMES
####################
# Define mountable directories.
VOLUME /data /raw /config

####################
# ENTRYPOINT
####################
#ENTRYPOINT ["/init"]
ADD docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
