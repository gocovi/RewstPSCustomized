$Functions = Get-ChildItem -Path $PSScriptRoot\Functions -Include *.ps1 -Recurse
Write-Verbose "Importing functions from $($Functions.Count) files from $PSScriptRoot\Functions"
$Functions | ForEach-Object {
    Write-Verbose "Importing function from $($_.FullName)"
    . $_.FullName
}

Export-ModuleMember -Function $Functions.BaseName -Alias *
