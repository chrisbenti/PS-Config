$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ROOT\..\Microsoft.PowerShell_profile.ps1"


Describe "When in a git repo with posh-git installed" {
    Mock Get-GitStatus { return $true; }
    
    Context "And neither posh-hg nor posh-svn are installed" {
        Get-HgStatus = $null
        Get-SvnStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-hg is installed" {
        Mock Get-HgStatus { return $false; }
        Get-SvnStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-svn is installed" {
        Mock Get-SvnStatus { return $false; }
        Get-HgStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-hg and posh-svn are installed" {
        Mock Get-SvnStatus { return $false; }
        Mock Get-HgStatus { return $false; }
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
}

Describe "When in a hg repo with posh-hg installed" {
    Mock Get-HgStatus { return $true; }
    
    Context "And neither posh-git nor posh-svn are installed" {
        Get-GitStatus = $null
        Get-SvnStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-git is installed" {
        Mock Get-GitStatus { return $false; }
        Get-SvnStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-svn is installed" {
        Mock Get-SvnStatus { return $false; }
        Get-GitStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-git and posh-svn are installed" {
        Mock Get-SvnStatus { return $false; }
        Mock Get-GitStatus { return $false; }
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
}

Describe "When in a svn repo with posh-svn installed" {
    Mock Get-SvnStatus { return $true; }
    
    Context "And neither posh-git nor posh-hg are installed" {
        Get-GitStatus = $null
        Get-HgStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-git is installed" {
        Mock Get-GitStatus { return $false; }
        Get-HgStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-hg is installed" {
        Mock Get-HgStatus { return $false; }
        Get-GitStatus = $null
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
    
    Context "And posh-git and posh-hg are installed" {
        Mock Get-HgStatus { return $false; }
        Mock Get-GitStatus { return $false; }
        
        It "Returns a positive status" {
            Get-VcsStatus | Should Be $true
        }
    }
}