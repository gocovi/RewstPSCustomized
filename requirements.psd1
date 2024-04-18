# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    # For latest supported version, go to 'https://www.powershellgallery.com/packages/Az'. 
    # To use the Az module in your function app, please uncomment the line below.
    # 'Az' = '9.*'
    'Microsoft.PowerShell.SecretManagement' = '1.1.2'
    'Az.KeyVault'                           = '5.2.2'
    'Az.Accounts'                           = '2.17.0'
}   
