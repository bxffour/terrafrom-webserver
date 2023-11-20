package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/keyvault/azsecrets"
)

type application struct {
	kvclient   *azsecrets.Client
	secretName string
}

func (a application) greet(w http.ResponseWriter, r *http.Request) {
	version := ""
	resp, err := a.kvclient.GetSecret(context.Background(), a.secretName, version, nil)
	if err != nil {
		log.Fatal(err)
	}

	message := *resp.Value

	fmt.Fprintf(w, "Hello World! %s\nThis is a message from Key Vault: \n%s\n", time.Now(), message)
}

func main() {
	secretName := "gosecret"
	vaultURI := os.Getenv("AZURE_KEY_VAULT_URI")

	cred, err := azidentity.NewEnvironmentCredential(nil)
	if err != nil {
		log.Fatal(err)
	}

	client, err := azsecrets.NewClient(vaultURI, cred, nil)
	if err != nil {
		log.Fatal(err)
	}

	app := application{kvclient: client, secretName: secretName}

	log.Println("server listening on port 8080")
	http.HandleFunc("/", app.greet)
	http.ListenAndServe(":8080", nil)
}
