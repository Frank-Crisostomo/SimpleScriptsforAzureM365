<#
  .SYNOPSIS
  Simple Script Series: This script fixes the context menu in Windows 11, to fully expand the right-click menu without the need to click on "Show More options".
  .DESCRIPTION
  This script fixes the context menu in Windows 11, to fully expand the right-click menu without the need to click on "Show More options".
  
  .PARAMETER OutputPath

  .INPUTS
  None. You cannot pipe objects to Fix_Windows11_Context_Menu.ps1.
  .OUTPUTS
  None.
  .EXAMPLE
  PS> .\Fix_Windows11_Context_Menu.ps1
    .NOTES
    
  .AUTHOR
  Francis Crisostomo 9/9/2023
#>

# Function to fix context menu
function FixContextMenu {
    # Check if registry key exists
    $CheckRegistrykey = Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -ErrorAction SilentlyContinue
    
    # If registry key exists, skip
     If ($CheckRegistrykey) {
       Write-Host "Registry key already exists"
     }
     # If registry key does not exist, create it
     Else {
       # Create registry key 
       New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force
       # Create registry value
       New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -PropertyType "String"
       Write-Host "Registry key added"
     }
  }
  
 # Run function
 FixContextMenu

 # You will have to restart your computer for the changes to take effect.
Write-Output "You will have to restart your computer for the changes to take effect."

 # End of Script