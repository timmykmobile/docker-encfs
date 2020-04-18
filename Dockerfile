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
    apt-get install -y nano && \
    rm -rf /var/lib/apt/lists/*

####################
# ENVIRONMENT VARIABLES
####################
# Encryption
ENV REVERSE "no" # set the default variable

####################
# VOLUMES
####################
# Define mountable directories.
# VOLUME /data /raw /config

####################
# ENTRYPOINT
####################
#ENTRYPOINT ["/init"]
ADD docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh

#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
