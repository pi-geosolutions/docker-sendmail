FROM debian:buster

MAINTAINER Jean Pommier "jean.pommier@pi-geosolutions.fr"

RUN apt-get update && \
    apt-get install -y --no-install-recommends sendmail && \
    rm -rf /var/lib/apt/lists/*

ENV HOSTNAME mydomain.com
ENV SUBNET=""

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
