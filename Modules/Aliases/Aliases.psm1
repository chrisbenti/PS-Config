function .. {cd ..}
function console {set-location "c:$($env:HOMEPATH)\Application Data\Console"}
function psc {set-location "c:$($env:HOMEPATH)\Documents\WindowsPowershell"}

function gst {git status}


function Colors {
    [ConsoleColor].DeclaredMembers | Select Name | Where {$_.Name -ne "value__" } |% {Write-Host $_.Name -f $_.Name}
}

function Get-Admin {
    cat .\UPNs.txt | ? {$_ -Match "admin"}
}

function which($name){
	Get-Command $name | Select-Object -ExpandProperty Definition
}

function ~ { cd ~ }
