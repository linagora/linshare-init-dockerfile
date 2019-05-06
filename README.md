Linshare init dockerfile
============================

This image will set up basic parameters of LinShare.
It will create a domain with a ldap connection.



Configuration
-------------

| Environment variable              | Default          | Description
|-----------------------------------|------------------|----------------------------------------------------------------------
| TOMCAT_HOST                       | backend          | LinShare backend ip or name
| TOMCAT_PORT                       | 8080             | LinShare backend port
| LS_PASSWORD                       | adminlinshare    | New password or root account.
| DEFAULT_PASSWORD                  | adminlinshare    | Old password used for first authentication.
| LINSHARE_USER_URL                 | https://....     | LinShare url used for email notifications for users
| LINSHARE_EXTERNAL_URL             | https://....     | LinShare url used for email notifications for anonymous (emails)
| NO_REPLY_ADDRESS                  | no-reply@...     | Sender of email notifications sent by LinShare.
|-----------------------------------|------------------|----------------------------------------------------------------------
| TOMCAT_LDAP_NAME                  | -                | If set, an ldap connection will be created with the first top domain.
| TOMCAT_LDAP_URL                   | ldap://ldap:389  | URI of your ldap
| TOMCAT_LDAP_DN                    | -                | Account dn used to loggin against your ldap. Leave empty is not used.
|                                   | -                |   ex: cn=linshare,dc=linshare,dc=org
| TOMCAT_LDAP_PW                    | -                | Account password used to loggin against your ldap. Leave empty is not used.
| TOMCAT_LDAP_BASE_DN               | -                | branch where LinShare will find your users.
|                                   | -                |   ex: ou=People,dc=linshare,dc=org
| TOMCAT_DOMAIN_PATTERN_NAME        | pattern-openldap | Name of the domain pattern that wil be created.
|                                   |                  | It will be created only if TOMCAT_LDAP_NAME is defined.
| TOMCAT_DOMAIN_PATTERN_MODEL       | 868400c0...      | Default domain pattern used as model (openldap model by default)
|-----------------------------------|------------------|----------------------------------------------------------------------
| EXTRA_INIT_SCRIPT                 | -                | Path to an extra script that should be trigger at the end of the main script.
|                                   |                  |   ex: /linagora/bin/extra.sh
| LINSHARE_JWT_PUB_KEY              | -                | Path to the public that should be added as trusted issuers for JWT tokens.
|                                   |                  |   ex: /linagora/data/public.pem
| LINSHARE_JWT_PUB_KEY_NAME         | -                | Name of the previous pubic key. Issuer name.
|                                   |                  |   ex: my-service
