# Terraform-webserver

This repository contains a Terraform configuration for deploying infrastructure on Microsoft Azure, coupled with an Ansible playbook for application deployment. The Terraform script creates a set of resources, including a Virtual Machine, Key Vault, and networking components. The Ansible playbook is invoked through a null resource provisioner to configure and deploy an application on the provisioned Azure infrastructure. The application can be accessed through port 8080 of the provisioned vm.
## Requirements

* You must have a [Microsoft Azure](https://azure.microsoft.com/) subscription.

* You must have the following installed:
  * [Terraform](https://www.terraform.io/) CLI
  * Azure CLI tool

* The code was written for:
  * Terraform v1.6.4 or later

* It uses the Terraform AzureRM Provider v3.8.0 that interacts with the many resources supported by Azure Resource Manager (AzureRM) through its APIs.

## Using the code

### Configure your access to Azure.

* **Authenticate using the Azure CLI.**

    Terraform must authenticate to Azure to create infrastructure.

    In your terminal, use the Azure CLI tool to set up your account permissions locally.

    ```bash
    az login  
    ```

    Your browser will open and prompt you to enter your Azure login credentials. After successful authentication, your terminal will display your subscription information.

    ```bash
    [
      {
        "cloudName": "<CLOUD-NAME>",
        "homeTenantId": "<HOME-TENANT-ID>",
        "id": "<SUBSCRIPTION-ID>",
        "isDefault": true,
        "managedByTenants": [],
        "name": "<SUBSCRIPTION-NAME>",
        "state": "Enabled",
        "tenantId": "<TENANT-ID>",
        "user": {
          "name": "<YOUR-USERNAME@DOMAIN.COM>",
          "type": "user"
        }
      }
    ]
    ```

    Find the `id` column for the subscription account you want to use.

    Once you have chosen the account subscription ID, set the account with the Azure CLI.

    ```bash
    az account set --subscription "<SUBSCRIPTION-ID>"
    ```

  * **Create a Service Principal.**

    A Service Principal is an application within Azure Active Directory with the authentication tokens Terraform needs to perform actions on your behalf. Update the `<SUBSCRIPTION_ID>` with the subscription ID you specified in the previous step.

```bash
$ az ad sp create-for-rbac --name terraformbxffour --role="Contributor" --role "User Access Administrator" --scopes="/subscriptions/<SUBSCRIPTION-ID>"

```
output:
```
    {
      "appId": "xxxxxx-xxx-xxxx-xxxx-xxxxxxxxxx",
      "displayName": "azure-cli-2022-xxxx",
      "password": "xxxxxx~xxxxxx~xxxxx",
      "tenant": "xxxxx-xxxx-xxxxx-xxxx-xxxxx"
    }
```
NOTE: This script needs the `User Access Administrator` role in addition to the `Contributor` role because it makes role assignments.

* **Set your environment variables.**

HashiCorp recommends setting these values as environment variables rather than saving them in your Terraform configuration.

In your terminal, set the following environment variables. Be sure to update the variable values with the values Azure returned in the previous command.

  * For MacOS/Linux:

```bash
$ export ARM_CLIENT_ID="<SERVICE_PRINCIPAL_APPID>"
$ export ARM_CLIENT_SECRET="<SERVICE_PRINCIPAL_PASSWORD>"
$ export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
$ export ARM_TENANT_ID="<TENANT_ID>"
```

  * For Windows (PowerShell):

```bash
$env:ARM_CLIENT_ID="<SERVICE_PRINCIPAL_APPID>"
$env:ARM_CLIENT_SECRET="<SERVICE_PRINCIPAL_PASSWORD>"
$env:ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
$env:ARM_TENANT_ID="<TENANT_ID>"
```

### Initialize Terraform configuration.

  The first command that should be run after writing a new Terraform configuration is the `terraform init` command to initialize a working directory containing Terraform configuration files. It is safe to run this command multiple times.

  If you ever set or change modules or backend configuration for Terraform, rerun this command to reinitialize your working directory. If you forget, other commands will detect it and remind you to do so if necessary.

  Run command:

```bash
$ terraform init
```

### Validate the changes.

The terraform plan command lets you see what Terraform will do before actually making any changes.

- Run command:
```bash
$ terraform plan
```

### Apply the changes.

The terraform apply command lets you apply your configuration, and it creates the infrastructure.

Run command:
```bash
$ terraform apply
```

### Clean up the resources created.

When you have finished, the terraform destroy command destroys the infrastructure you created.

Run command:
```bash
$ terraform destroy
```

## Terraform Variables

These are the variables that can be customized to tailor the deployment according to your requirements.

| Variable Name  | Type    | Description                                                                                                                      | Default Value                |
| -------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `name_prefix`  | String  | Name prefix used for resources. Should only contain lowercase characters and hyphens.                                         | `shtan-app-`                 |
| `location`     | String  | Azure Region where all resources in this example should be created.                                                             | `West Europe`                |
| `vm_admin_user`| String  | Admin user name for the virtual machine.                                                                                        | `shtech`                     |
| `vm_image`     | Object  | Linux virtual machine image configuration.                                                                                    | See Default Configuration   |
| `app_version`  | String  | Version of the app to be installed on the VM.                                                                                  | `0.2.0`                      |

### Default Configuration for `vm_image`

```hcl
{
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts"
  version   = "latest"
}
```

### Version Validation

The `app_version` follows Semantic Versioning (SemVer) syntax. It must match the pattern `MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`. The default version is `0.2.0`.
