package main

import (
  "fmt"
  "net/http"
  "os"
)

func handler(w http.ResponseWriter, r *http.Request) {
  commit := os.Getenv("COMMIT")
  secret := os.Getenv("SECRET")
  fmt.Fprintf(w, "Hello World! COMMIT=%s SECRET=%s", commit, secret)
}

func main() {
  fmt.Println("Starting myhttpserver...")
  http.HandleFunc("/", handler)
  http.ListenAndServe(":8080", nil)
}
