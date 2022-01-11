FROM python:3.8-slim-buster

MAINTAINER LinShare <linshare@linagora.com>

ARG VERSION="5.0.0-rc1-1"
ARG CHANNEL="releases"

ENV LINSHARE_VERSION=$VERSION

RUN pip install linsharecli
RUN mkdir -p /linagora/data
WORKDIR /linagora


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
ENV LS_UPLOAD_REQUEST_URL "https://upload-request.linshare.local"
ENV LS_NO_REPLY_ADDRESS no-reply@linshare.org

ENV LS_EXTRA_INIT_SCRIPT ""

ENV LS_JWT_PUB_KEY "/linagora/data/public.pem"
ENV LS_JWT_PUB_KEY_NAME ""

ENV LS_FORCE_INIT 0
ENV LS_DEBUG 0

COPY bin /linagora/bin

ENV WAITFORIT_STRICT 1
ENV WAITFORIT_TIMEOUT 15

ENTRYPOINT ["/linagora/bin/init.sh"]
