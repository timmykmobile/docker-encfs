FROM ubuntu:latest
MAINTAINER timmykmobile

# Update Software repository
RUN apt-get update

# install build packages
RUN apt-get install -y encfs && \
    rm -rf /var/lib/apt/lists/*

# add local files
ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]

#ENTRYPOINT ["/init"]
