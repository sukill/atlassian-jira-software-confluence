#!/bin/bash
set -euo pipefail

# Setup Catalina Opts
: ${CATALINA_CONNECTOR_PROXYNAME:=}
: ${CATALINA_CONNECTOR_PROXYPORT:=}
: ${CATALINA_CONNECTOR_SCHEME:=http}
: ${CATALINA_CONNECTOR_SECURE:=false}
: ${CATALINA_CONTEXT_PATH:=}
: ${CATALINA_CERT_LOCATION:=}
: ${CATALINA_KEYSTORE_PASS:=}
: ${CATALINA_KEY_ALIAS:=letsencrypt}
: ${CATALINA_OPTS:=}

CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyName=${CATALINA_CONNECTOR_PROXYNAME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyPort=${CATALINA_CONNECTOR_PROXYPORT}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorScheme=${CATALINA_CONNECTOR_SCHEME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorSecure=${CATALINA_CONNECTOR_SECURE}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaContextPath=${CATALINA_CONTEXT_PATH}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaCertLocation=${CATALINA_CERT_LOCATION}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaKeystorePass=${CATALINA_KEYSTORE_PASS}"

export CATALINA_OPTS

keytool -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -storepass ${CATALINA_KEYSTORE_PASS} -file ${CATALINA_CERT_LOCATION} -alias ${CATALINA_KEY_ALIAS}

# Start Confluence as the correct user
if [ "${UID}" -eq 0 ]; then
    echo "User is currently root. Will change directory ownership to ${RUN_USER}:${RUN_GROUP}, then downgrade permission to ${RUN_USER}"
    PERMISSIONS_SIGNATURE=$(stat -c "%u:%U:%a" "${JIRA_HOME}")
    EXPECTED_PERMISSIONS=$(id -u ${RUN_USER}):${RUN_USER}:700
    if [ "${PERMISSIONS_SIGNATURE}" != "${EXPECTED_PERMISSIONS}" ]; then
        chmod -R 700 "${JIRA_HOME}" &&
            chown -R "${RUN_USER}:${RUN_GROUP}" "${JIRA_HOME}"
    fi
    # Now drop privileges
    exec su -s /bin/bash "${RUN_USER}" -c "$JIRA_INSTALL_DIR/bin/start-jira.sh $@"
else
    exec "$JIRA_INSTALL_DIR/bin/start-jira.sh" "$@"
fi

