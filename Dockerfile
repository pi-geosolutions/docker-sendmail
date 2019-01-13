FROM debian:stretch

MAINTAINER Jean Pommier "jean.pommier@pi-geosolutions.fr"

RUN apt-get update && \
    apt-get install -y --no-install-recommends sendmail && \
    rm -rf /var/lib/apt/lists/*

ENV HOSTNAME mydomain.com
ENV SUBNET 10.42

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
