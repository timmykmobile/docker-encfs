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
ENV ENCFS_REVERSE=0 \
    ENCFS_XML_NAME=encfs.xml \
    ENCFS_PASSWORD_NAME=encfspass


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
RUN echo user_allow_other >> /etc/fuse.conf \
    && chmod +x /docker-entrypoint.sh

#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
