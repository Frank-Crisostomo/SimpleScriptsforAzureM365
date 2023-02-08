<# 
Simple Script Series: Update UPN for All Users in Azure AD Tenant
Created by Frank Crisostomo 2/6/2023
#>

<#
  .SYNOPSIS
  Simple Script Series: Update UPN for All Users in Azure AD Tenant

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
    Version:        1.2.8.23
    Simple Script Series: Update UPN for All Users in Azure AD Tenant
    Updated by Frank Crisostomo 2/7/2023
#>

# Install AzureAD Module
Install-Module AzureAD

# Connect to AzureAD        
Connect-AzureAD

# Variables for old and new domains
$OldDomain = "Contoso.com"
$NewDomain = "contoso.onmicrosoft.com"

# Check that new domain exist
$GetDomain = Get-AzureADDomain -Name $NewDomain
    If ($GetDomain){Write-Host "Domain" $NewDomain "exists" -ForegroundColor Green} Else {Write-Host "Domain" $NewDomain "does not exist" -ForegroundColor Red}

# Get all AzureAD Users that are not Guest(B2B) Accounts
$Users = Get-AzureADUser -All $true | Where-Object {($_.UserPrincipalName -notlike $NewDomain) -and ($_.UserType -ne 'Guest')}

# For each user from the list of $Users
    Foreach($User in $Users){

    # Get there current UPN
    $OldUPN = $user.UserPrincipalName

    # Create the new UPN by replacing the domain in the variable $NewUPN
    $NewUPN = $user.UserPrincipalName -replace $OldDomain, $NewDomain

    # Optional output
    Write-Host $user.UserPrincipalName "Updating to" $NewUPN -ForegroundColor Yellow

    # Set $NewUPN
    Set-AzureADUser -UserPrincipalName $NewUPN

    # Check that UPN has been updated
    $UpdatedUser = Get-AzureADUser -ObjectId $NewUPN
    If ($UpdatedUser){Write-Host $OldUPN "Updated to" $UpdatedUser.UserPrincipalName -ForegroundColor Green}
    Else {Write-Host $OldUPN "Failed to update" -ForegroundColor Red}
    }

# Disconnect from AzureAD
Disconnect-AzureAD

# End of Script
