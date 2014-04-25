

function sudo
{
    $file, [string]$arguments = $args;
    $psi = new-object System.Diagnostics.ProcessStartInfo $file;
    $psi.Arguments = $arguments;
    $psi.Verb = "runas";
    $psi.WorkingDirectory = get-location;
    [System.Diagnostics.Process]::Start($psi);
}


function .. {cd ..}

function psc {set-location "c:$($env:HOMEPATH)\Documents\WindowsPowershell"}

function gst {git status}

function which($name){
	Get-Command $name | Select-Object -ExpandProperty Definition
}

function ~ { cd ~ }

function Get-ColorPairs { 
    $colors = [ConsoleColor].DeclaredMembers | Where {$_.Name -ne "value__" }

    $colors | % {
        $a = $_.Name
        $colors | % {
            $b = $_.Name
            Write-Host "FG: $a | BG: $b" -f $a -b $b
        }
    }
}