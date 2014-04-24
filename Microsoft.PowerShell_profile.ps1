Import-Module PsGet
Import-Module PSUrl
Import-Module Aliases
Import-Module PowerTab
Import-Module SyncMeUp
Import-Module Work -ErrorAction SilentlyContinue

# Constants
$SPACER = [char]11136

$colors = @{}
$colors["blue"] = ([ConsoleColor]::Blue, [ConsoleColor]::DarkBlue)
$colors["green"] = ([ConsoleColor]::Green, [ConsoleColor]::DarkGreen)
$colors["cyan"] = ([ConsoleColor]::Cyan, [ConsoleColor]::DarkCyan)
$colors["red"] = ([ConsoleColor]::Red, [ConsoleColor]::DarkRed)
$colors["magenta"] = ([ConsoleColor]::Magenta, [ConsoleColor]::DarkMagenta)
$colors["yellow"] = ([ConsoleColor]::Yellow, [ConsoleColor]::DarkYellow)
$colors["gray"] = ([ConsoleColor]::Gray, [ConsoleColor]::DarkGray)






if(Test-Path ~\.last) {
    (Get-Content ~\.last) | set-location
    rm ~\.last
}


# Makes git diff work
$env:TERM = "msys"

Set-Alias subl "C:\Program Files\Sublime Text 3\sublime_text.exe"


function prompt { 

    $realLASTEXITCODE = $LASTEXITCODE

    $drive = (get-drive (pwd).Path)

    $color = [ConsoleColor]::Cyan
    $bgcolor = [ConsoleColor]::DarkCyan
    switch ($drive){
        "\\"    {
            $color = [ConsoleColor]::Green
            $bgcolor = [ConsoleColor]::DarkGreen
        }  
    }

    write-host " " -n -b $bgcolor
    write-host $drive -n -f $color -b $bgcolor
    write-host (shorten-path (pwd).Path) -n -f $color -b $bgcolor
    write-host " " -n -b $bgcolor

    if(Vanilla-Window ){
        write-host " > " -n
    } else {
        write-host -f $bgcolor $SPACER -n
    }

    return " " 
} 



function Vanilla-Window{
    (Get-Location).Path > ~\.last
    $process = get-process | ?{$_.ID -eq $pid}
    if($process.MainWindowTitle.Equals("")){
        # Console
        return $false
    } else {
        # Powershell 
        return $true
    }
}


# Utility for prompt()
function get-drive( [string] $path ) {
    if( $path.StartsWith( $HOME ) ) {
        return "~"
    } elseif( $path.StartsWith( "Microsoft.PowerShell.Core" ) ){
        return "\\"
    } else {
        return $path.split( "\" )[0]
    }
}


function shorten-path([string] $path) { 
    $loc = $path.Replace($HOME, '~') 


    # remove prefix for UNC paths 
    $loc = $loc -replace '^[^:]+::', '' 


    $drive = get-drive (pwd).Path
    $loc = $loc.TrimStart( $drive )


    # make path shorter like tabs in Vim, 
    # handle paths starting with \\ and . correctly 
    return ($loc -replace '\\(\.?)([^\\]{3})[^\\]*(?=\\)','\$1$2') 
}