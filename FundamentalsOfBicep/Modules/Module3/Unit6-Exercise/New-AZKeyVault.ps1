$keyVaultName = Read-Host -Prompt "Name of the new Key Vault"
$keyVaultLogin = Read-Host -Prompt "Enter the desired login name"
$keyVaultPassword = Read-Host -Prompt "Enter the desired login password" -AsSecureString

try {
    az keyvault create --name $keyVaultName --location eastus --enabled-for-template-deployment true
} catch {
    Write-Error "Error creating Key Vault. Details: $($_.Exception.Message)"
}

try {
    az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorLogin" --value $keyVaultLogin --output none
} catch {
    Write-Error "Error setting Key Vault secret for sqlServerAdministratorLogin"
}

try {
    az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorPassword" --value $keyVaultPassword --output none
} catch {
    Write-Error "Error setting Key Vault secret for sqlServerAdministratorPassword"
}
