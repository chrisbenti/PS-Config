$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ROOT\..\Microsoft.PowerShell_profile.ps1"


Describe "Version control repositories" {
    Context "whose root directories" {
        $rootdir = "C:/Test"
        
        It "Is-VCSRoot returns true at the root of a git repository" {
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
            $dir = "$rootdir/.git";
            mkdir $dir -force
        
            Is-VCSRoot $dir | Should be $true
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
        }
        
        It "Is-VCSRoot returns true at the root of a hg repository" {
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
            $dir = "$rootdir/.hg";
            mkdir $dir -force
        
            Is-VCSRoot $dir | Should be $true
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
        }
        
        It "Is-VCSRoot returns true at the root of a svn repository" {
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
            $dir = "$rootdir/.svn";
            mkdir $dir -force
        
            Is-VCSRoot $dir | Should be $true
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
        }
        
        It "Is-VCSRoot returns not true when not at the root of a repository" {
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
            mkdir $rootdir -force
        
            Is-VCSRoot $dir | Should not be $true
            rm $rootdir -recurse -force -ErrorAction SilentlyContinue
        }
    }
}