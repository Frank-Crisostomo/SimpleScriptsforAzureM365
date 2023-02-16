<#
.SYNOPSIS
Simple Script Series: Update UPN for All Users in Azure AD Tenant.
.DESCRIPTION
This script updates the UPN for all users in an Azure AD Tenant. This script is part of the Simple Script Series. The Simple Script Series is a collection of scripts that perform simple tasks. The scripts are designed to be easy to understand and modify.
.PARAMETER InputPath
None.
.PARAMETER OutputPath
.INPUTS
None. You cannot pipe objects to Update_UPN_For_All_Users_in_AAD.ps1.
.OUTPUTS
None.
.EXAMPLE
PS> .\Update_UPN_For_All_Users_in_AAD.ps1
.NOTES
Scenario: Update UPN for All Users in Azure AD Tenant after adding a new domain to Azure AD.

Version: 1.2.8.23
Simple Script Series: Update UPN for All Users in Azure AD Tenant
Updated by Frank Crisostomo 2/8/2023
#>

# Checks module, if missing it installs
if (!(Get-Module AzureAD)) {
    Install-Module AzureAD
}

# Connect to AzureAD        
Connect-AzureAD

# Variables for old and new domains
$NewDomain = "contoso.com"
$OldDomain = "contoso.onmicrosoft.com"

# Check that new domain exists
if (Get-AzureADDomain -Name $NewDomain) {
    Write-Verbose "Domain $NewDomain exists"
} else {
    Write-Error "Domain $NewDomain does not exist"
}

# Get all AzureAD Users that are not guest accounts
$Users = Get-AzureADUser -All $true | Where-Object {!($_.UserPrincipalName -contains $NewDomain) -and ($_.UserType -ne 'Guest')}

# For each user from the list of $Users
foreach ($User in $Users) {
    # Get their current UPN
    $OldUPN = $User.UserPrincipalName

    # Create the new UPN by replacing the domain in the variable $NewUPN
    $NewUPN = $OldUPN -replace $OldDomain, $NewDomain

    # Output the update
    Write-Verbose "Updating $OldUPN to $NewUPN"

    # Set the new UPN
    Set-AzureADUser -ObjectId $OldUPN -UserPrincipalName $NewUPN

    # Check that UPN has been updated
    if (Get-AzureADUser -ObjectId $NewUPN) {
        Write-Verbose "$OldUPN updated to $NewUPN"
    } else {
        Write-Error "$OldUPN failed to update"
    }
}

# Disconnect from AzureAD
Disconnect-AzureAD

# End of script
