#!/bin/bash

[[ ! -d ssl ]] && mkdir ssl
[[ ! -d artifacts/ssl ]] && mkdir artifacts/ssl
[[ ! -f artifacts/ssl/ca.pem ]] && cfssl gencert -initca ssl/ca-csr.json | cfssljson -bare artifacts/ssl/ca
[[ ! -f artifacts/ssl/localtest.pem ]] && cfssl gencert -ca=artifacts/ssl/ca.pem -ca-key=artifacts/ssl/ca-key.pem -config=ssl/ca-config.json -profile=server ssl/localtest.json | cfssljson -bare artifacts/ssl/localtest

MARIADB_VERSION="10.4"
if [[ ! -z ${1} ]]; then
    MARIADB_VERSION="${1}"
    shift
fi

# set -ex

docker run -d --rm \
--name mariadb-test \
--env "MYSQL_USER=localuser" \
--env "MYSQL_PASSWORD=localpass" \
--env "MYSQL_DATABASE=localtest" \
--env "MYSQL_ROOT_PASSWORD=rootpass" \
--mount "type=bind,src=$(pwd)/artifacts/ssl,target=/etc/mysql/ssl" \
--mount "type=bind,src=/dev/null,target=/etc/mysql/conf.d/docker.cnf" \
-p 3306:3306/tcp \
mariadb:${MARIADB_VERSION} --ssl --ssl-ca=/etc/mysql/ssl/ca.pem --ssl-cert=/etc/mysql/ssl/localtest.pem --ssl-key=/etc/mysql/ssl/localtest-key.pem --performance-schema-hosts-size=100 --performance_schema=on
