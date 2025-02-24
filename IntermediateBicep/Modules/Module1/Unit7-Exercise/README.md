# Module 1 Unit 7 Exercise

- [Exercise - Deploy extension resources and use existing resources](https://learn.microsoft.com/en-us/training/modules/child-extension-bicep-templates/7-exercise-deploy-extension-existing-resources?pivots=cli)

## Notes

- After connecting to the Concierge subscription & learn-xxx resource group, run the following command to create a Log Analytics Workspace for this exercise:
  - `az monitor log-analytics workspace create --workspace-name ToyLogs --location eastus`
- Also create a storage account:
  - `az storage account create --name {storageaccountname} --location eastus`
    - Replace `{storageaccountname}` with a name of your choosing.
    - The name must be unique, no longer than 24 characters, and can only use lowercase letters and integers.
- When deploying the template, pass a `--parameters storageAccountName={storageaccountname}`, using the same `{storageaccountname}` you set above:
  - `az deployment group create --name main --template-file main.bicep --parameters storageAccountName={storageaccountname}`
