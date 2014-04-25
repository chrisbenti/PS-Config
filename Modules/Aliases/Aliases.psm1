Set-Alias subl "C:\Program Files\Sublime Text 3\sublime_text.exe"

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

function Colors {
    [ConsoleColor].DeclaredMembers | Select Name | Where {$_.Name -ne "value__" } |% {Write-Host $_.Name -f $_.Name}

    $colors = @{}
    $colors["blue"] = ([ConsoleColor]::Blue, [ConsoleColor]::DarkBlue)
    $colors["green"] = ([ConsoleColor]::Green, [ConsoleColor]::DarkGreen)
    $colors["cyan"] = ([ConsoleColor]::Cyan, [ConsoleColor]::DarkCyan)
    $colors["red"] = ([ConsoleColor]::Red, [ConsoleColor]::DarkRed)
    $colors["magenta"] = ([ConsoleColor]::Magenta, [ConsoleColor]::DarkMagenta)
    $colors["yellow"] = ([ConsoleColor]::Yellow, [ConsoleColor]::DarkYellow)
    $colors["gray"] = ([ConsoleColor]::Gray, [ConsoleColor]::DarkGray)

    $colors.Keys | % {
        Write-Host  " $_ " -f $colors[$_][0] -b $colors[$_][1]
    }
}

function which($name){
	Get-Command $name | Select-Object -ExpandProperty Definition
}

function ~ { cd ~ }
