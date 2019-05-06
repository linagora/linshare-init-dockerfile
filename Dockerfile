FROM ubuntu:18.04

MAINTAINER LinShare <linshare@linagora.com>

RUN apt update && apt-get install -q -y python-pip python-dev build-essential wget

RUN pip install linsharecli
RUN mkdir -p /linagora/data
WORKDIR /linagora

RUN wget --no-check-certificate --progress=bar:force:noscroll \
 "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" \
 -O /linagora/wait-for-it.sh && chmod 755 /linagora/wait-for-it.sh

ENV TOMCAT_HOST backend
ENV TOMCAT_PORT 8080

ENV TOMCAT_LDAP_NAME ""
ENV TOMCAT_LDAP_URL ldap://ldap:389
ENV TOMCAT_LDAP_BASE_DN ""
ENV TOMCAT_LDAP_DN ""
ENV TOMCAT_LDAP_PW ""
ENV LS_PASSWORD adminlinshare
ENV DEFAULT_PASSWORD adminlinshare

ENV TOMCAT_DOMAIN_PATTERN_NAME "pattern-openldap"
ENV TOMCAT_DOMAIN_PATTERN_MODEL "868400c0-c12e-456a-8c3c-19e985290586"

ENV LINSHARE_USER_URL "https://user.linshare.local"
ENV LINSHARE_EXTERNAL_URL "https://user.linshare.local"
ENV NO_REPLY_ADDRESS no-reply@linshare.org

ENV EXTRA_INIT_SCRIPT ""

ENV LINSHARE_JWT_PUB_KEY "/linagora/data/public"
ENV LINSHARE_JWT_PUB_KEY_NAME ""

COPY bin /linagora/bin

ENTRYPOINT ["/linagora/wait-for-it.sh", "-t", "15", "${TOMCAT_HOST}:${TOMCAT_PORT}", "--", "/linagora/bin/init.sh"]
