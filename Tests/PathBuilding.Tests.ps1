$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ROOT\..\Microsoft.PowerShell_profile.ps1"

Describe "UNC Shares" {
    if ($env:CI) {
        Mock Get-Home { return "c:/User/" }
    }

    Context "When navigated to a UNC share" {
        It "Shorten-Path returns all parts after the share name" {
            Shorten-Path "\\localhost\c$" | Should Be ""
            Shorten-Path "\\localhost\c$\Windows" | Should be "Windows"
            Shorten-Path "\\localhost\c$\Windows\System32" | Should be "Win\System32"
        }

        It "Get-Drive returns the name of the share" {
            Get-Drive "Microsoft.PowerShell.Core\FileSystem::\\localhost\c$\Windows\System32" | Should be "\\localhost\c$"
            Get-Drive "Microsoft.PowerShell.Core\FileSystem::\\localhost\c$" | Should be "\\localhost\c$"
        }
    }
}

Describe "Drive Directories" {
    if ($env:CI) {
        Mock Get-Home { return "c:/User/" }
    }
    
    Context "When in the C:\Windows\system32 directory" {
        It "Returns all parts after the C:\" {
            Shorten-Path "C:\Windows\System32" | Should Be "Win\System32"   
        }
    }
}
