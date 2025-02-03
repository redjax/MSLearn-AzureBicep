# Microsoft Learn Bicep

- [Exercise - Define resources in a Bicep template](https://learn.microsoft.com/en-us/training/modules/build-first-bicep-template/4-exercise-define-resources-bicep-template?pivots=cli)

## Notes

- Install/upgrade Bicep with `az bicep install && az bicep upgrade`
- Log into Azure CLI with `az login`
- Set default subscription (i.e. to the sandbox "Concierge Subscription"): `az account set --subscription "Concierge Subscription"`
  - If you have multiple subscriptions, you can search for a string within a subscription name like:

```shell
az account list \
    --refresh \
    --query "[?contains(name, 'Concierge Subscription')].id" \
    --output table
```

  - After listing all subscriptions, set your default with: `az account set --subscription {your subscription ID}`
- While practicing, you can set your resource group to the sandbox RG with: `az configure --defaults group="learn-ed47cb2d-1d81-4f91-a814-fc5da88c9f01"`
- Deploy a template with `az deployment group create --template-file path/to/main.bicep`
- After running a deploy, you can verify it with: `az deployment group list --output table`
