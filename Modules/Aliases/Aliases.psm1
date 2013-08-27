function .. {cd ..}
function console {set-location "c:$($env:HOMEPATH)\Application Data\Console"}
function psc {set-location "c:$($env:HOMEPATH)\Documents\WindowsPowershell"}

function gst {git status}


function Colors {
    [ConsoleColor].DeclaredMembers | Select Name | Where {$_.Name -ne "value__" } |% {Write-Host $_.Name -f $_.Name}
}