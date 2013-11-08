function .. {cd ..}
function console {set-location "c:$($env:HOMEPATH)\Application Data\Console"}
function psc {set-location "c:$($env:HOMEPATH)\Documents\WindowsPowershell"}

function gst {git status}


function Colors {
    [ConsoleColor].DeclaredMembers | Select Name | Where {$_.Name -ne "value__" } |% {Write-Host $_.Name -f $_.Name}
}

function view {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]$content
    )

    $file = $env:temp + "\TEMP-" + [System.Guid]::NewGuid().toString() + ".txt"
    write-output $content > $file
    write-host $file
    & "C:\Program Files\Sublime Text 3\sublime_text.exe" $file
    start-job -InputObject $file -ScriptBlock{start-sleep 1; rm $input} | out-null
}

function ~ { cd ~ }