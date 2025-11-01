#!/bin/sh

set +x

CONFIG_FILE="/etc/postsrsd.conf"
SECRET_FILE="/etc/postsrsd.secret"

: ${SRS_DOMAIN:=localhost.localnet}
# Generate by running 'dd if=/dev/random bs=18 count=1 | base64'
: ${SRS_SECRET:="setthistoaverylongstring"}
: ${SRS_EXCLUDE_DOMAINS:=""}
: ${SRS_SEPARATOR:="="}
: ${SRS_SOCKET_PORT:=10003}
: ${SRS_MILTER_PORT:=9997}
: ${SRS_HASHLENGTH:=4}
: ${SRS_HASHMIN:=4}
: ${SRS_RUN_AS:=postsrsd}
: ${SRS_CHROOT:=/var/lib/postsrsdr}
: ${SRS_LISTEN_ADDRESS:="0.0.0.0"}
: ${SRS_MILTER_LISTEN_ADDRESS:="0.0.0.0"}
: ${SRS_OG_ENVELOPE:="embedded"}
: ${SRS_REDIS_HOST:="postsrsd-valkey"}
: ${SRS_DEBUG:="off"}

mkdir -p ${SRS_CHROOT}
chown -R ${SRS_RUN_AS} ${SRS_CHROOT}

echo "domains = { ${SRS_EXCLUDE_DOMAINS} }" > "${CONFIG_FILE}"
echo "srs-domain = ${SRS_DOMAIN}" >> "${CONFIG_FILE}"
echo "socketmap = inet:${SRS_LISTEN_ADDRESS}:${SRS_SOCKET_PORT}" >> "${CONFIG_FILE}"
echo "keep-alive = 30" >> "${CONFIG_FILE}"
echo "original-envelope = embedded" >> "${CONFIG_FILE}"
echo "secrets-file = \"${SECRET_FILE}\"" >> "${CONFIG_FILE}"
echo "separator = \"${SRS_SEPARATOR}\"" >> "${CONFIG_FILE}"
echo "hash-length = ${SRS_HASHLENGTH}" >> "${CONFIG_FILE}"
echo "hash-minimum = ${SRS_HASHMIN}" >> "${CONFIG_FILE}"
echo "always-rewrite = off" >> "${CONFIG_FILE}"
echo "unprivileged-user = ${SRS_RUN_AS}" >> "${CONFIG_FILE}"
echo "chroot-dir = ${SRS_CHROOT}" >> "${CONFIG_FILE}"
echo "syslog = off" >> "${CONFIG_FILE}"
if [ ${SRS_OG_ENVELOPE} = "redis" ]; then
    echo "original-envelope = database" >> "${CONFIG_FILE}"
    echo "envelope-database = redis:${SRS_REDIS_HOST}:6379" >> "${CONFIG_FILE}"
else
    echo "original-envelope = embedded" >> "${CONFIG_FILE}"
fi
echo "milter = inet:${SRS_MILTER_LISTEN_ADDRESS}:${SRS_MILTER_PORT}" >> "${CONFIG_FILE}"
if [ ${SRS_DEBUG} = "on" ]; then
    echo "debug = on" >> "${CONFIG_FILE}"
fi


echo "${SRS_SECRET}" > "${SECRET_FILE}"

# Turn off bash debug, and prepend datetime to every outputed line.
#set +x
echo "$(date +'%Y-%m-%d %H:%M:%S') - Starting postsrsd"
/app/postsrsd -C "${CONFIG_FILE}" 2>&1 | while IFS= read -r line; do echo "$(date +'%Y-%m-%d %H:%M:%S') - $line"; done

