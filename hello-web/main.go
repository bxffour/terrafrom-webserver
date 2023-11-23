package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/keyvault/azsecrets"
)

var (
	buildTime string
	version   string
	goVersion string
)

type application struct {
	kvclient   *azsecrets.Client
	secretName string
}

// This handler pulls a secret from the key vault and prints it out
func (a application) greet(w http.ResponseWriter, r *http.Request) {
	version := ""
	resp, err := a.kvclient.GetSecret(context.Background(), a.secretName, version, nil)
	if err != nil {
		log.Fatalf("error getting secret from keyvault: %v", err)
	}

	message := *resp.Value

	fmt.Fprintf(w, "Hello World! %s\nThis is a message from Key Vault: \n%s\n", time.Now(), message)
}

func main() {
	var printVersion bool

	flag.BoolVar(&printVersion, "version", false, "print the version and exit")
	flag.Parse()

	if printVersion {
		fmt.Printf("Version:\t%s\n", version)
		fmt.Printf("Build time:\t%s\n", buildTime)
		fmt.Printf("Go Version:\t%s\n", goVersion)
		os.Exit(0)
	}

	secretName := "gosecret"
	vaultURI := os.Getenv("AZURE_KEY_VAULT_URL")

	cred, err := azidentity.NewManagedIdentityCredential(nil)
	if err != nil {
		log.Fatalf("error getting creds for managed Identity: %v", err)
	}

	client, err := azsecrets.NewClient(vaultURI, cred, nil)
	if err != nil {
		log.Fatalf("error getting azclient: %v", err)
	}

	app := application{kvclient: client, secretName: secretName}

	log.Println("server listening on port 8080")
	http.HandleFunc("/", app.greet)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
