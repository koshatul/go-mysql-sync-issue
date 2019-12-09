#!/bin/bash

for MARIADB_VERSION in 10.{0,1,2,3,4}; do
    echo "## Testing MariaDB ${MARIADB_VERSION}"
    # docker pull mariadb:${MARIADB_VERSION}
    echo "++ starting MariaDB"
    ./mariadb.sh "${MARIADB_VERSION}" > /dev/null
    echo -n "Waiting for server to be ready: "
    while ! $(mysql -h mysql.localtest.me -u root -prootpass -NBe';' >/dev/null 2>&1); do sleep 1; echo -n "."; done
    echo ""
    echo "MariaDB Version: $(mysql -h mysql.localtest.me -u root -prootpass -NBe'select VERSION();')"
    echo "++ Running tests"
    ./run.sh
    echo "++ stopping mariadb-test"
    docker stop mariadb-test
done

for MYSQL_VERSION in 5.7 8.0; do
    echo "## Testing MySQL ${MYSQL_VERSION}"
    echo "++ starting MySQL"
    ./mysql.sh "${MYSQL_VERSION}" > /dev/null
    echo -n "Waiting for server to be ready: "
    while ! $(mysql -h mysql.localtest.me -u root -prootpass -NBe';' >/dev/null 2>&1); do sleep 1; echo -n "."; done
    echo ""
    echo "MySQL Version: $(mysql -h mysql.localtest.me -u root -prootpass -NBe'select VERSION();')"
    echo "++ Running tests"
    ./run.sh
    echo "++ stopping mysql-test"
    docker stop mysql-test
done
