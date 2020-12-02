#!/bin/bash

set -e

g_command=$1
g_base_directory=$(dirname $0)
g_prog_name=$(basename $0)
g_ls_cfg_file="/root/.linshare-admin-cli.cfg"
# if LS_START_DEBUG=1, debug traces will be displayed.
export LS_START_DEBUG=${LS_START_DEBUG:-0}

g_vars_list="LS_SERVER_HOST \
LS_SERVER_PORT \
LS_LDAP_URL \
LS_USER_URL \
LS_EXTERNAL_URL \
LS_PASSWORD \
LS_NO_REPLY_ADDRESS \
"
g_vars_extra_list="LS_LDAP_DN \
LS_LDAP_PW \
LS_LDAP_BASE_DN \
LS_LDAP_NAME \
LS_FORCE_INIT \
LS_DOMAIN_PATTERN_NAME \
LS_DOMAIN_PATTERN_MODEL \
LS_EXTRA_INIT_SCRIPT \
LS_JWT_PUB_KEY \
LS_JWT_PUB_KEY_NAME \
"

### Functions ####

# Description: This method will check and display a list of env variables.
#              The value of every env variables with names containing SECRET or
#              PASSWORD will be troncated (only the first 4 characters).
# First parameter is `mode`:
# * mode=0 : just display env vars
# * mode=1 : the script will abort if some env var is missing.
# Second parameter is `legend`:
# * legend=0 : do not display the legend
# * legend=1 : display the legend
# Next parameters : ENV variables to test
# ex: check_env_variables 1 1 VAR1 VAR2 VAR4
function check_env_variables ()
{
    local l_mode=${1}
    local l_legend=${2}
    shift
    shift
    local l_error=0
    local l_key=
    local l_vars_list=$@

    if [ ${l_legend} -eq 1 ] ; then
        if [ ${l_mode} -eq 1 ] ; then
            echo "INFO:${g_prog_name}: Checking all required env variables..."
        else
            echo "INFO:${g_prog_name}: Checking all optional env variables..."
        fi
    fi
    for l_key in ${l_vars_list}
    do
        if [[ ${l_key} =~ PASSWORD || ${l_key} =~ SECRET || ${l_key} =~ LDAP_PW ]] ; then
            if [ ${LS_START_DEBUG} -eq 1 ] ; then
                echo "${l_key} : ${!l_key}"
            else
                echo "${l_key} : ${!l_key:0:4}..."
            fi
        else
            echo "${l_key} : ${!l_key}"
        fi
        if [ ${l_mode} -eq 1 ] ; then
            if [ -z ${!l_key} ] ; then
                l_error=1
            fi
        fi
    done
    if [ ${l_error} -eq 1 ] ; then
        echo "ERROR: Missing some input variables"
        exit 1
    fi
    [ ${l_legend} -eq 1 ] && echo -e "INFO:${g_prog_name}: All env variables checked\n"
    return ${l_error}
}

function create_config_file() {
    local l_tomcat_url="http://${LS_SERVER_HOST}:${LS_SERVER_PORT}"

    echo  "[server]" > $g_ls_cfg_file
    echo  "host=${l_tomcat_url}" >> $g_ls_cfg_file
    echo  "user=root@localhost.localdomain" >> $g_ls_cfg_file
    echo  "auth_type=plain" >> $g_ls_cfg_file
}

function init_basic_ls_cfg() {
    echo "INFO:${g_prog_name}: update the domain notification url"
    linshareadmcli -E funcs update-str DOMAIN__NOTIFICATION_URL ${LS_USER_URL}
    linshareadmcli -E funcs update-str DOMAIN__MAIL ${LS_NO_REPLY_ADDRESS}

    # update the anonymous notification url
    echo "INFO:${g_prog_name}: update the anonymous notification url"
    linshareadmcli -E funcs update-str ANONYMOUS_URL__NOTIFICATION_URL ${LS_EXTERNAL_URL}

    # enable GUEST functionalities.
    echo "INFO:${g_prog_name}: disable GUESTS functionalities"
    linshareadmcli -E funcs update --enable GUESTS

    echo "INFO:${g_prog_name}: disable documents expiration"
    linshareadmcli -E funcs update --disable DOCUMENT_EXPIRATION

    if [ -z ${LS_JWT_PUB_KEY_NAME} ] ; then
        echo "INFO:${g_prog_name}: JWT extra key name was to set. skipped."
    else
        if [ -f ${LS_JWT_PUB_KEY} ] ; then
            l_pattern="^${LS_JWT_PUB_KEY_NAME}$"
            if [ $(linshareadmcli -E pubkeys list "${l_pattern}" -c --cli-mode) -ne 1 ] ; then
                linshareadmcli -E pubkeys create --key ${LS_JWT_PUB_KEY} ${LS_JWT_PUB_KEY_NAME}
            fi
        else
            echo "WARN:${g_prog_name}: JWT extra key file does not exist."
        fi
    fi
}

function init_domains() {

    echo "INFO:${g_prog_name}: creation of top domain 1 ..."
    if [ ${LS_DOMAIN_POLICY_AUTO} -eq 1 ] ; then
        g_domain_top1=$(linshareadmcli -E domains create --type TOPDOMAIN ${LS_DOMAIN_NAME} --domain-policy-auto --cli-mode)
    else
        g_domain_top1=$(linshareadmcli -E domains create --type TOPDOMAIN ${LS_DOMAIN_NAME} --cli-mode)
    fi
    echo "INFO:${g_prog_name}: g_domain_top1: ${g_domain_top1}"

    # create ldap connection
    if [ ! -z ${LS_LDAP_NAME} ] ; then
        g_ldap_connect=$(linshareadmcli -E ldap create \
            --provider-url ${LS_LDAP_URL} \
            --principal "${LS_LDAP_DN}" \
            --credential "${LS_LDAP_PW}" \
            ${LS_LDAP_NAME} --cli-mode)

        # create domain pattern
        g_domain_patterns=$(linshareadmcli -E \
            dpatterns create --model ${LS_DOMAIN_PATTERN_MODEL} \
            ${LS_DOMAIN_PATTERN_NAME} --cli-mode)
        echo "INFO:${g_prog_name}: g_ldap_connect: ${g_ldap_connect}"
        echo "INFO:${g_prog_name}: g_domain_patterns: ${g_domain_patterns}"

        linshareadmcli -E domains setup --ldap ${g_ldap_connect} --dpattern \
        ${g_domain_patterns} --basedn "${LS_LDAP_BASE_DN}" ${g_domain_top1}
    fi

    echo "INFO:${g_prog_name}: creation of guest domain ..."
    linshareadmcli -E domains create \
        --type GUESTDOMAIN guestdomain --parent ${g_domain_top1}
}

### Main ####
if [ -z $@ ] ; then
    check_env_variables 1 1 ${g_vars_list}
    check_env_variables 0 1 ${g_vars_extra_list}
    if [ ${LS_DEBUG} -eq 1 ] ; then
        set -x
    fi
    export WAITFORIT_PORT=${LS_SERVER_PORT}
    export WAITFORIT_HOST=${LS_SERVER_HOST}
    if [ -f ${g_base_directory}/wait-for-it.sh ] ; then
        ${g_base_directory}/wait-for-it.sh
    fi
    create_config_file
    linshareadmcli --password-from-env LS_DEFAULT_PASSWORD auth update --new-password-from-env LS_PASSWORD
    linshareadmcli -E auth me
    linshareadmcli -E domains list  -k identifier -k label -k description
    res=$(linshareadmcli -E domains list -c --cli-mode)
    if [ ${LS_FORCE_INIT} -eq 1 ] ; then
        echo "INFO:${g_prog_name}:LS_FORCE_INIT: nb domains=${res}"
        res=1
    else
        echo "INFO:${g_prog_name}: nb domains = ${res}"
    fi
    if [ $res -eq 1 ] ; then
        echo "INFO:${g_prog_name}: Configuration of LinShare Backend ..."
        init_basic_ls_cfg
        init_domains
        if [ ! -z ${LS_EXTRA_INIT_SCRIPT} ] ; then
            for l_script in ${LS_EXTRA_INIT_SCRIPT}
            do
                if [ -f ${l_script} ] ; then
                    echo "INFO:${g_prog_name}: running: source ${l_script}"
                    source ${l_script}
                else
                    echo "WARN:${g_prog_name}: ./${l_script} does not exist"
                fi
            done
        fi
        echo "INFO:${g_prog_name}: Configuration of LinShare Backend ... done"
    else
        echo "INFO:${g_prog_name}: LinShare backend already initialized."
    fi
    linshareadmcli -E domains list  -k identifier -k label -k description
else
    if [ ${LS_DEBUG} -eq 1 ] ; then
        set -x
    fi
    ${@}
fi
