package main

import (
	"log"
	"net/http"
	"time"
)

func main() {
	startTime := time.Now()

	http.HandleFunc("/startupz", func(w http.ResponseWriter, r *http.Request) {
		if time.Since(startTime) < 30*time.Second {
			http.Error(w, "Server is starting up", http.StatusServiceUnavailable)
			return
		}

		w.Write([]byte("OK"))
		w.WriteHeader(http.StatusOK)
	})

	http.HandleFunc("/livez", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
		w.WriteHeader(http.StatusOK)
	})

	http.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
		w.WriteHeader(http.StatusOK)
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})

	log.Println("Starting server on :8080")
	http.ListenAndServe(":8080", nil)
}
