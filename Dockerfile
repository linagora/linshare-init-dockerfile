FROM ubuntu:18.04

MAINTAINER LinShare <linshare@linagora.com>

RUN apt update && apt-get install -q -y python-pip wget

RUN pip install linsharecli==0.4.6
RUN mkdir -p /linagora/data
WORKDIR /linagora

RUN wget --no-check-certificate --progress=bar:force:noscroll \
 "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" \
 -O /linagora/wait-for-it.sh && chmod 755 /linagora/wait-for-it.sh

ENV LS_SERVER_HOST backend
ENV LS_SERVER_PORT 8080

ENV LS_LDAP_NAME ""
ENV LS_LDAP_URL ldap://ldap:389
ENV LS_LDAP_BASE_DN ""
ENV LS_LDAP_DN ""
ENV LS_LDAP_PW ""
ENV LS_PASSWORD adminlinshare
ENV LS_DEFAULT_PASSWORD adminlinshare

ENV LS_DOMAIN_PATTERN_NAME "pattern-openldap"
ENV LS_DOMAIN_PATTERN_MODEL "868400c0-c12e-456a-8c3c-19e985290586"
ENV LS_DOMAIN_POLICY_AUTO 0
ENV LS_DOMAIN_NAME "top1"

ENV LS_USER_URL "https://user.linshare.local"
ENV LS_EXTERNAL_URL "https://user.linshare.local"
ENV LS_NO_REPLY_ADDRESS no-reply@linshare.org

ENV LS_EXTRA_INIT_SCRIPT ""

ENV LS_JWT_PUB_KEY "/linagora/data/public.pem"
ENV LS_JWT_PUB_KEY_NAME ""

ENV LS_FORCE_INIT 0
ENV LS_DEBUG 0

COPY bin /linagora/bin

ENTRYPOINT ["/linagora/wait-for-it.sh", "-t", "15", "${LS_SERVER_HOST}:${LS_SERVER_PORT}", "--", "/linagora/bin/init.sh"]
