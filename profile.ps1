# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.
if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity
}

$SecretVault = Get-SecretVault | Where-Object { $_.VaultParameters.AZKVaultName -eq "GoCoviScripting" }

if (!$SecretVault) {
    Write-Host "Registering secret vault..."
    $VaultParams = @{
        Name            = "GoCoviScriptingKeyVault";
        ModuleName      = "Az.KeyVault";
        VaultParameters = @{ 
            AZKVaultName   = "GoCoviScripting"; 
            SubscriptionId = "0a36f53e-28ba-4206-bba2-a9af92f9245e" 
        };
        DefaultVault    = $true;
    }

    Register-SecretVault @VaultParams
}

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.
