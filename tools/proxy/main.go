package main

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"net/http"
)

var disableBatchRequest bool

func main() {
	// Handy flag to disable batch request on the fly.
	flag.BoolVar(&disableBatchRequest, "disable-batch-request", false, "Disable batch requests")
	flag.Parse()
	if disableBatchRequest {
		fmt.Println("Batch requests are disabled")
	}

	// Start the HTTP server.
	http.HandleFunc("/", handleRequest)
	fmt.Println("Server listening on :8080")
	http.ListenAndServe(":8080", nil)
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
	// Read the request.
	msg, err := io.ReadAll(r.Body)
	if err != nil {
		_, _ = w.Write([]byte(fmt.Sprintf("Unable to read the request: %v", err)))
		return
	}
	fmt.Printf("Request received: %v\n", string(msg))

	// Check if the request is a batch.
	if disableBatchRequest && isBatchRequest(msg) {
		fmt.Println("Batch requests are not authorised!")
		_, _ = w.Write([]byte("Batch requests are not authorised!"))
		return
	}

	// Format the request.
	req, err := http.NewRequest(http.MethodPost, "http://localhost:8545", bytes.NewReader(msg))
	if err != nil {
		_, _ = w.Write([]byte(fmt.Sprintf("Unable to create the request: %v", err)))
		return
	}
	req.Header.Set("Content-Type", "application/json")

	// Send the request.
	var client http.Client
	res, err := client.Do(req)
	if err != nil {
		_, _ = w.Write([]byte(fmt.Sprintf("Unable to send the request: %v", err)))
		return
	}

	// Read the response.
	resp, err := io.ReadAll(res.Body)
	if err != nil {
		_, _ = w.Write([]byte(fmt.Sprintf("Unable to read the response: %v", err)))
		return
	}
	fmt.Printf("Response received: %v\n", string(resp))

	// Send the response back to the client.
	if _, err = w.Write(resp); err != nil {
		_, _ = w.Write([]byte(fmt.Sprintf("Unable to send the request to the client: %v", err)))
		return
	}
	res.Body.Close()
}

func isBatchRequest(raw []byte) bool {
	// Byte representation of characters.
	var spaceChar = byte(0x20)
	var horizontalTabChar = byte(0x09)         // \t
	var newLineChar = byte(0x0a)               // \n
	var carriageReturnChar = byte(0x0d)        // \r
	var openingSquaredBracketChar = byte(0x5b) // [

	for _, c := range raw {
		if c == spaceChar || c == horizontalTabChar || c == newLineChar || c == carriageReturnChar {
			continue
		}
		return c == openingSquaredBracketChar
	}
	return false
}
