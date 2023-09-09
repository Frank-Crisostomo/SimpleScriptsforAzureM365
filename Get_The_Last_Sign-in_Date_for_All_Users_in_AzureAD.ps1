<#
.SYNOPSIS
	Get the last sign-in date for all users in AzureAD/EntraID.
.DESCRIPTION
	This PowerShell script retrieves the sign-in date for all users in an AzureAD/EntraID tenant using the Microsoft Graph API. It then saves the data to an Azure Table Storage table. This script can be used in an Azure Automation Runbook to get the last sign-in date for all users in an Azure AD tenant on a schedule and post it to a table in Azure Table Storage. This script can be modify to run locally on a computer or server if you have obtain the Azure AD App Client ID and Client Secret. It can also be modify to save the data to a CSV file. Once the data is in the Azure Table Storage, you can use Power BI to create a report. https://docs.microsoft.com/en-us/power-bi/connect-data/desktop-connect-azure-tables or export to CSV.
.PARAMETER

.EXAMPLE
	
.LINK

.Requirements
    - AzureAD PowerShell Module (https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0) This script will check and install for you.
    - AzTable PowerShell Module (https://www.powershellgallery.com/packages/AzTable/0.1.0) This script will check and install for you. This script will check and install for you.
    - Azure Automation Account  (https://docs.microsoft.com/en-us/azure/automation/automation-quickstart-create-account?tabs=azure-powershell)
    - Azure AD App with permission to read users in directory. https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app
    - Azure Storage Account with a table. https://docs.microsoft.com/en-us/azure/storage/tables/table-storage-overview
    - Azure Automation Account Variables. https://docs.microsoft.com/en-us/azure/automation/automation-variables
    - Azure Table Storage SAS Token. https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview
    - Azure Automation Runbook. https://docs.microsoft.com/en-us/azure/automation/automation-runbook-types (Optional) You will paste this script into a PowerShell Runbook on the Azure Automation Account.
    - Azure Automation Schedule. https://docs.microsoft.com/en-us/azure/automation/automation-schedules (Optional) You can schedule this runbook to run on a schedule.
 
.NOTES
This script is part of the Simple Script Series. The Simple Script Series is a collection of scripts that perform simple tasks. The scripts are designed to be easy to understand and modify.
This script can be used in an Azure Automation Runbook to get the last sign-in date for all users in an Azure AD tenant on a schedule and post it to a table in Azure Table Storage.
This script can be modify to run locally on a computer or server if you have obtain the Azure AD App Client ID and Client Secret. It can also be modify to save the data to a CSV file.

Once the data is in the Azure Table Storage, you can use Power BI to create a report. https://docs.microsoft.com/en-us/power-bi/connect-data/desktop-connect-azure-tables or export to CSV.

Updated by Francis Crisostomo. 9/9/2023
#>

# Checks module, if missing it installs (AztTable)
$CheckModule = Get-Module aztable
if (!$CheckModule){Install-Module aztable}

# Store the values of the variables for this runbook in the Azure Automation Account, instead of the script for better security.
# Set automation account variables used in this runbook. They are stored as encrypted variables in the automation account.
# This is assigning the values of the automation account variables to the variables used in this runbook.

$storageAccountName = Get-AutomationVariable -Name 'LastSignInUsersStorageAccount' # This is the name of the storage account where the table is stored.
$tableName = Get-AutomationVariable -Name 'LastSignTable' # This is the name of the table where the data is stored.
$sasToken = Get-AutomationVariable -Name 'LastSignInUserSASToken' # This is the SAS token for the storage account.
$TenantId = Get-AutomationVariable -Name 'TenantID' # This is the Tenant ID for the Azure AD tenant.
$AppClientId= Get-AutomationVariable -Name 'LastSignInUsersAppClientID' # This is the App Client ID for the Azure AD App.
$ClientSecret = Get-AutomationVariable -Name 'LastSignInUsersClientSecret' # This is the Client Secret for the Azure AD App.

# Set execution policy to bypass for this process
Set-ExecutionPolicy Bypass -Scope Process -Force


# Setup Azure table function
Write-Output "Setting up ClearTable function"
Function ClearTable {
        $datetime = Get-Date
        $partitionKey = "Users"
        $processes = @()

        Write-Output "Connecting to Azure Storabe Table"
        # Connect to Azure Table Storage
        $Ctx = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken
        $storageTable = (Get-AzStorageTable -Name $TableName -Context $ctx).CloudTable

        # Empty previous content on table
        # Get all rows and pipe the result into the remove cmdlet.
        Get-AzTableRow -table $StorageTable | Remove-AzTableRow -table $StorageTable 
}

# Clear previous table. You can comment out the next two lines if you want to keep the previous data in the table.
Write-Output "Clearing previous table"
ClearTable -EA 0

#  Function to add data to Azure Table
Write-Output "Setting up AddToTable function"
Function AddtoTable {
$partitionKey = "Users"
$processes = @()

# Connect to Azure Table Storage
$Ctx = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken
$storageTable = (Get-AzStorageTable -Name $TableName -Context $ctx).CloudTable

# Get the data 
$processes = $User

    # Write data to Table storage
    Write-Output "Adding $DisplayName to Azure table"
    foreach ($process in $processes) {
        Add-AZTableRow -table $storagetable -Verbose -partitionKey $partitionKey -rowKey ([guid]::NewGuid().tostring()) -property @{
        "Created" = $Extension_Attributes.createdDateTime
        "LastSignInDateTime" = if($User.lastSignInDateTime) { [DateTime]$User.lastSignInDateTime } Else {""}
        "DisplayName" = $user.displayName
        "UserPrincipalName" = $user.userPrincipalName
		"Enabled" = $AccountEnabled
        
        }
    }
}

#  Connecting to MS Graph API to pull the data
Write-output "GET from MS Graph API"
  
$RequestBody = @{client_id=$AppClientId;client_secret=$ClientSecret;grant_type="client_credentials";scope="https://graph.microsoft.com/.default";}
$OAuthResponse = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token -Body $RequestBody
$AccessToken = $OAuthResponse.access_token
 
#Form request headers with the acquired $AccessToken
$headers = @{'Content-Type'="application\json";'Authorization'="Bearer $AccessToken"}
 
#This request get users list with signInActivity.
$ApiUrl = "https://graph.microsoft.com/beta/users?`$select=displayName,userPrincipalName,signInActivity,userType"
 
$Result = @()
While ($ApiUrl -ne $Null) #Perform pagination if next page link (odata.nextlink) returned.
{
$Response = Invoke-WebRequest -Method GET -Uri $ApiUrl -ContentType "application\json" -Headers $headers -UseBasicParsing | ConvertFrom-Json
    if($Response.value)
    {
    $Users = $Response.value
        ForEach($User in $Users){
            $Result += New-Object PSObject -property $([ordered]@{ 
            DisplayName = $User.displayName
            UserPrincipalName = $User.userPrincipalName
            LastSignInDateTime = if($User.signInActivity.lastSignInDateTime) { [DateTime]$User.signInActivity.lastSignInDateTime } Else {$null}
            })
            
        }
    }
$ApiUrl=$Response.'@odata.nextlink'
}

# Foreach loop to process each user
Foreach ($User in $Result){                             
    
    # Add to Azure Table
    AddtoTable                    
 }
 
# Processing Completed
Write-Output "Processing Completed get-date -Format 'yyyy-MM-dd HH:mm:ss' "

# End of Script