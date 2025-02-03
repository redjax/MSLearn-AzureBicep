# Microsoft Learn - Fundamentals of Bicep <!-- omit in toc -->

Notes & code from working through the [Fundamentals of Bicep course on Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/fundamentals-bicep/)

Paths in the [FundamentalsOfBicep/Modules](./FundamentalsOfBicep/Modules) directory represent learning modules along the Fundamentals of Bicep training path. I did not create examples for each and every modules, only the ones that have us write code or that I took notes on.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Microsoft Learn Modules](#microsoft-learn-modules)
- [Notes](#notes)
  - [Set your Azure CLI to use the Sandbox subscription created in MS Learn](#set-your-azure-cli-to-use-the-sandbox-subscription-created-in-ms-learn)
    - [Find the concierge/sandbox subscription in Azure Portal](#find-the-conciergesandbox-subscription-in-azure-portal)
    - [Find the concierge/sandbox subscription with the CLI](#find-the-conciergesandbox-subscription-with-the-cli)
    - [Full example](#full-example)
  - [Test a Bicep template by building it](#test-a-bicep-template-by-building-it)
  - [Do a deployment dry-run](#do-a-deployment-dry-run)
  - [Log in to an Azure environment from the AZ CLI](#log-in-to-an-azure-environment-from-the-az-cli)
  - [Get a Key Vault's ID](#get-a-key-vaults-id)

## Microsoft Learn Modules

- [Module 1 - Introduction to infrastructure as code using Bicep](https://learn.microsoft.com/en-us/training/modules/introduction-to-infrastructure-as-code-using-bicep/)

- [Module 2 - Build your first Bicep template](https://learn.microsoft.com/en-us/training/modules/build-first-bicep-template/)
  - [Code](./FundamentalsOfBicep/Modules/Module2/)

- [Module 3 - Build reusable Bicep templates by using parameters](https://learn.microsoft.com/en-us/training/modules/build-reusable-bicep-templates-parameters/)
  - [Code](./FundamentalsOfBicep/Modules/Module3/)

- [Module 4 - Build flexible Bicep templates by using conditionals and loops](https://learn.microsoft.com/en-us/training/modules/build-flexible-bicep-templates-conditions-loops/)

- [Module 5 - Create composable Bicep files by using modules](https://learn.microsoft.com/en-us/training/modules/create-composable-bicep-files-using-modules/)

## Notes

### Set your Azure CLI to use the Sandbox subscription created in MS Learn

#### Find the concierge/sandbox subscription in Azure Portal

- Navigate to [portal.azure.com](https://portal.azure.com)
- Click your name/portrait in the top right of the screen and choose "Switch directory"
- Click the `Switch` button on the "Microsoft Learn Sandbox" subscription
  - If you do not see this subscription, check to see if you've filtered by "Favorites," and if so, click "All Directories"

#### Find the concierge/sandbox subscription with the CLI

As you work through Microsoft Learn paths for Azure Bicep, you will see some sections have an option to initialize an Azure Sandbox for you to work in. Switching to the sandbox subscription (also called the 'Concierge' subscription) lets you apply your Bicep templates to a sandboxed environment, completely isolated from any other Azure environments your account has access to.

You can use the `az account list` command to show all of the subscriptions available to the account you've logged into (with `az login`), or you can use the command below to filter your subscriptions to show only the sandbox:

```shell
az account list --refresh --query "[?contains(name, 'Concierge Subscription')].id" --output table
```

Then you can set that account as your active subscription for `az` commands:

```shell
az account set --subscription {your subscription ID}
```

You can also set a default resource group so you don't have to add it to each `az` command:

```shell
az configure --defaults group="[sandbox resource group name]"
```

List all Azure resource groups in the current subscription:

```shell
az group list --output table
```

Search for a resource group:

Use the `--query` arg to search for a resource group by a partial string:

```shell
az group list --query "[?contains(name, '<your-partial-search-string>')] --output table
```

For example, to search for the Microsoft Learn sandbox you created:

```shell
az group list --query "[?contains(name, 'learn-')]" --output table
```

#### Full example

**Note:** These commands will only work after you create a sandbox in the Microsoft Learn module, using the sandbox section at the top of `Exercise` modules.

Below is a full example of the sequence of commands you can use to switch to the Azure Sandbox created in the Microsoft Learn documentation:

```powershell
## Log into the Azure CLI
#  This is not necessary if you have already logged into the Azure CLI.
az login

## Find the Azure subscription for the sandbox environment.
#  Copy and paste the subscription Id in the 'Result' table
az account list --refresh --query "[?contains(name, 'Concierge Subscription')].id" --output table

## Set your active subscription using the subscription ID from the last command
az account set --subscription $SandboxSubscriptionID

## List available resource groups in the Azure Learn sandbox subscription
az group list --query "[?contains(name, 'learn-')]" --output table

## Set the active resource group to the 'learn-{GUID}' ID from the last command
az configure --defaults group="learn-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Test a Bicep template by building it

If the template builds, it is likely valid; you still need to check inputs and params you create, but if you can compile the Bicep template to JSON, the structure is sound and the template should apply.

Build & show output in the CLI:

```shell
az bicep build --file path/to/<template-name>.bicep --stdout
```

To compile the template to JSON, you can use:

```shell
az bicep build --file path/to/<template-name>.bicep
```

You can change where the JSON file is outputted with the `--out` arg:

```shell
az bicep build --file path/to/<template-name>.bicep --out path/to/<output-filename>.json
```

### Do a deployment dry-run

You can use the `deployment <type> validate` command to do a deployment dry run to see if the template will deploy successfully.

For resource group scopes:

```shell
az deployment group validate --resource-group <resource-group-name> --template-file path/to/<template-name>.bicep
```

For subscription scopes:

```shell
az deployment sub validate --template-file <template-filename>.bicep
```

For management group/tenant scopes:

```shell
az deployment mg validate --management-group-id <management-group-id> --template-file <template-name>.bicep
az deployment tenant validate --template-file <template-name>.bicep
```


### Log in to an Azure environment from the AZ CLI

```powershell
az login
```

This command will open a prompt window asking you to select a Microsoft account if you're already signed into one, or will ask you to sign in. This links the Azure `az` CLI to your Azure tenant.

After login, you will be prompted to select a subscription. After creating a sandbox in the Microsoft Learn module (at the top of the page), look for on that has a `Tenant` value of `Microsoft Learn Sandbox`; this subscription should be called `Concierge Subscription`. Make sure to select this testing environment when going through the modules!

### Get a Key Vault's ID

```shell
az keyvault show --name $keyVaultName --query id --output tsv
```
