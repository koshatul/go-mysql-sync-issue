# go-mysql-sync-issue

Testing for issue with golang mysql driver returning obscure error.

## Testing

```bash
$ mariadb.sh
2019/12/09 14:08:33 [INFO] generating a new CA key and certificate from CSR
2019/12/09 14:08:33 [INFO] generate received request
2019/12/09 14:08:33 [INFO] received CSR
2019/12/09 14:08:33 [INFO] generating key: rsa-2048
2019/12/09 14:08:33 [INFO] encoded CSR
2019/12/09 14:08:33 [INFO] signed certificate with serial number 353762979413037507529987064092921871088550223650
2019/12/09 14:08:33 [INFO] generate received request
2019/12/09 14:08:33 [INFO] received CSR
2019/12/09 14:08:33 [INFO] generating key: rsa-2048
2019/12/09 14:08:33 [INFO] encoded CSR
2019/12/09 14:08:33 [INFO] signed certificate with serial number 586624177981560466172941170980825070783742489454
154858dbaff9ea5eed0ec8efc3f57d939b22903da8e4c1ba486d9602ac92e819
```

wait for the mysql server to become available:

```bash
$ docker logs -tf mysql-test
....
2019-12-09T04:10:27.244919369Z 2019-12-09  4:10:27 0 [Note] mysqld: ready for connections.
2019-12-09T04:10:27.244925918Z Version: '10.4.10-MariaDB-1:10.4.10+maria~bionic'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution
```

then run go test

```bash
$ go run main.go
2019/12/09 14:11:23 Initial Ping Error: %!s(<nil>)
2019/12/09 14:11:23 Final Ping Error: commands out of sync. Did you run multiple statements at once?
```

which isn't very readable, because the actual error is:

```text
$ mysql --ssl-ca ssl/ca.pem -h mysql.localtest.me -u localuser -plocalpass localtest
ERROR 1129 (HY000): Host '172.17.0.1' is blocked because of many connection errors; unblock with 'mysqladmin flush-hosts'
```
