package main

import (
	"fmt"
	"log"
	"net/http"
)

var port = "80"

func main() {
	// Serve static files from the "static" directory
	http.Handle("/", http.FileServer(http.Dir("static")))

	// Start the HTTP server on the specified port
	address := fmt.Sprintf(":%s", port)
	log.Printf("Starting server on %s", address)
	err := http.ListenAndServe(address, nil)
	if err != nil {
		log.Fatal("Error starting server: ", err)
	}
}
