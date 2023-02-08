<# 
Simple Script Series: Update UPN for All Users in Azure AD Tenant
Created by Frank Crisostomo 2/6/2023
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
