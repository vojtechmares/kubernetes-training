package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"text/template"

	"github.com/google/uuid"
)

const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Hello, Kubernetes! | {{ .Hostname }}</title>
  <style>
    body {
      font-family: Helvetica;
    }
    pre {
      margin: 0.25rem 0;
      font-size: 1.5rem;
    }
  </style>
</head>
<body style="font-family: Helvetica">
  <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
    <h1 style="font-size: 4rem;">Hello, Kubernetes! 👋</h1>
    <pre>hostname: {{ .Hostname }}</pre>
    <pre>instanceID: {{ .InstanceID }}</pre>
  </div>
</body>
</html>
`

func main() {
	instanceID := uuid.New().String()
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		tpl, err := template.New("index.html").Parse(html)
		if err != nil {
			log.Println(err)
			w.Write([]byte(fmt.Sprintf("Error: %s", err)))
			return
		}

		err = tpl.Execute(w, map[string]string{"Hostname": hostname, "InstanceID": instanceID})
		if err != nil {
			log.Println(err)
			w.Write([]byte(fmt.Sprintf("Error: %s", err)))
			return
		}

		w.Header().Set("Content-Type", "text/html")
	})

	log.Println("Starting server on :8080")
	http.ListenAndServe(":8080", nil)
}
