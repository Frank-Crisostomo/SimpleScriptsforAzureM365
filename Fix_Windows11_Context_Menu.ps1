<#
  .SYNOPSIS
  Simple Script Series: Fix Context Menu in Windows 11.
  .DESCRIPTION
 This script will fix the context menu in Windows 11 so that it functions like Windows 10.
  None.
  .PARAMETER OutputPath
  .INPUTS
  None.
  .OUTPUTS
  None.
  .EXAMPLE
  PS> .\Fix_Windows11_Context_Menu.ps1
    .NOTES
    Simple Script Series: Fix context menu in Windows 11, returning to Windows 10 functionality. No administrator privileges required. This only applies to the current user running the script.
    Updated by Francis Crisostomo 9/9/2023
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