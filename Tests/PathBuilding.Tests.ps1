$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ROOT\..\Microsoft.PowerShell_profile.ps1"

Describe "Get-Provider" {
    if ($env:CI) {
        Mock Get-Home { return "c:/User/" }
    }
    
    Context "Determining the provider" {
        It "Should handle the FileSystem" {
            Get-Provider "C:\Windows\System32" | Should Be "FileSystem"
        }

        It "Should handle Cert:" {
            Get-Provider "Cert:\CurrentUser\CA" | Should Be "Certificate"
        }

        It "Should handle SMB shares" {
            Get-Provider "\\localhost\c$\Windows\System32" | Should Be "FileSystem"
        }

        It "Should handle the registry" {
            Get-Provider "HKLM:\SOFTWARE\Microsoft" | Should Be "Registry"
        }
    }
}

Describe "UNC Shares" {
    if ($env:CI) {
        Mock Get-Home { return "c:/User/" }
    }

    Context "When navigated to a UNC share" {
        It "Get-Drive returns the name of the share" {
            Get-Drive "Microsoft.PowerShell.Core\FileSystem::\\localhost\c$\Windows\System32" | Should be "\\localhost\c$\"
            Get-Drive "Microsoft.PowerShell.Core\FileSystem::\\localhost\c$" | Should be "\\localhost\c$\"
        }
        It "Shorten-Path returns all parts after the share name" {
            Shorten-Path "\\localhost\c$" | Should Be ""
            Shorten-Path "\\localhost\c$\Windows" | Should be "Windows"
            Shorten-Path "\\localhost\c$\Windows\System32" | Should be "Win\System32"
        }
    }
}

Describe "Drive Directories" {
    if ($env:CI) {
        Mock Get-Home { return "c:/User/" }
    }
    
    Context "When in the C:\Windows\system32 directory" {
        It "Get-Drive returns C:\" {
            Get-Drive "C:\Windows\System32" | Should be "C:\"
        }
        It "Shorten-Path returns all parts after the C:\" {
            Shorten-Path "C:\Windows\System32" | Should Be "Win\System32"   
        }
    }
}

Describe "PowerShell non-FileSystem Providers" {
    if ($env:CI) {
        Mock Get-Home { return "c:/User/" }
    }

    Context "When in the cert provider"{
        It "Get-Drive should return something" {
            Get-Drive "Cert:\CurrentUser\CA" | Should Be "Cert:\"
        }
        It "Shorten-Path should return the rest of the directory" {
            Shorten-Path "Cert:\CurrentUser\CA" | Should Be "CurrentUser\CA"
        }
    }
}