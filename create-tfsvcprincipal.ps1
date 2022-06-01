##########################################################################################
# Create Service Principal for TF Authentication 
##########################################################################################

$env:AZ_SERVICE_PRINCIPAL = "tf-service-principal"

Connect-AzAccount

$env:TF_VAR_SUBSCRIPTION_ID= (Get-AzSubscription).Id
$env:TF_VAR_TENANT_ID= (Get-AzSubscription).TenantId

Set-AzContext -Subscription $env:TF_VAR_SUBSCRIPTION_ID
$sp = New-AzADServicePrincipal -DisplayName $env:AZ_SERVICE_PRINCIPAL -Role "Contributor"

Write-Output "Subscription ID: $env:TF_VAR_SUBSCRIPTION_ID"
Write-Output "Tenant ID: $env:TF_VAR_TENANT_ID"
Write-Output "App ID: $sp.AppId.AppId"
Write-Output "App Password: $sp.PasswordCredentials.SecretText"
