# Azure Functions profile.ps1

# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.
if ($env:MSI_SECRET) {
    $ExpirationDate = $null
    $AccessToken = $null

    function Get-Secret {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Name,

            # This is just for compatibility with the existing code
            [Parameter()]
            [switch]$AsPlainText
        )

        if ($null -eq $AccessToken -or $ExpirationDate -lt (Get-Date)) {
            $Params = @{
                Uri     = "$env:MSI_ENDPOINT`?resource=https://vault.azure.net&api-version=2017-09-01"
                Method  = 'GET'
                Headers = @{ Secret = $env:MSI_SECRET }
            }

            $AuthResponse = (Invoke-RestMethod @Params)
            $AccessToken = $AuthResponse.access_token
            $ExpirationDate = $AuthResponse.expires_on -as [DateTime]
        }

        # Key Vault details
        $KeyVaultName = "GoCoviScripting"  # Replace with your Key Vault name
        $SecretUri = "https://$KeyVaultName.vault.azure.net/secrets/$Name"

        # Retrieve secret using the access token
        $SecretParams = @{
            Uri     = $SecretUri
            Method  = 'GET'
            Body    = @{'api-version' = '7.4' }
            Headers = @{
                'Authorization' = "Bearer $AccessToken"
                'Content-Type'  = 'application/json'
            }
        }

        $SecretResponse = Invoke-RestMethod @SecretParams

        # Extract the secret value
        $SecretResponse.value
    }
}

Get-ChildItem -Path "$PSScriptRoot\modules" -Filter *.psd1 | ForEach-Object {
    try {
        Import-Module $_.FullName
    }
    catch {
        Write-Warning "Failed to import module $($_.FullName): $_"
    }
}