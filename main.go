package main

import (
	"crypto/tls"
	"crypto/x509"
	"database/sql"
	"io/ioutil"
	"log"

	mysql "github.com/go-sql-driver/mysql"
)

func main() {
	rootCertPool := x509.NewCertPool()

	pem, err := ioutil.ReadFile("artifacts/ssl/ca.pem")
	if err != nil {
		log.Fatal(err)
	}

	if ok := rootCertPool.AppendCertsFromPEM(pem); !ok {
		log.Fatal("Failed to append PEM.")
	}

	if err := mysql.RegisterTLSConfig("custom", &tls.Config{RootCAs: rootCertPool}); err != nil {
		panic(err)
	}

	dsn := "localuser:localpass@tcp(mysql.localtest.me:3306)/localtest?tls=custom"
	func() {
		db, _ := sql.Open("mysql", dsn)
		defer db.Close()

		err := db.Ping()
		log.Printf("Initial Ping Error: %s", err)
	}()

	dsn = "localuser:localpass@tcp(mysql2.localtest.me:3306)/localtest?tls=custom"
	for i := 0; i < 110; i++ {
		func() {
			dsn := dsn
			db, _ := sql.Open("mysql", dsn)
			defer db.Close()
			_ = db.Ping()
		}()
	}

	dsn = "localuser:localpass@tcp(mysql.localtest.me:3306)/localtest?tls=custom"
	func() {
		db, _ := sql.Open("mysql", dsn)
		defer db.Close()

		err := db.Ping()
		log.Printf("Final Ping Error: %s", err)
	}()
}
