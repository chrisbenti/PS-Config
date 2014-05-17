############################### Module Imports ###############################
Import-Module PsGet
Import-Module PSUrl
Import-Module Aliases
Import-Module PowerTab
Import-Module SyncMeUp
Import-Module Work -ErrorAction SilentlyContinue
Import-Module posh-git
############################### Module Imports ###############################



################################## Constants #################################
$FANCY_SPACER = [char]11136
$GIT_BRANCH = [char]11104
$FANCY_X = [char]10008

$colors = @{}
$colors["blue"] = ([ConsoleColor]::Cyan, [ConsoleColor]::DarkBlue)
$colors["green"] = ([ConsoleColor]::Green, [ConsoleColor]::DarkGreen)
$colors["cyan"] = ([ConsoleColor]::Cyan, [ConsoleColor]::DarkCyan)
$colors["red"] = ([ConsoleColor]::Red, [ConsoleColor]::DarkRed)
$colors["magenta"] = ([ConsoleColor]::Magenta, [ConsoleColor]::DarkMagenta)
$colors["yellow"] = ([ConsoleColor]::Yellow, [ConsoleColor]::DarkYellow)
$colors["gray"] = ([ConsoleColor]::White, [ConsoleColor]::DarkGray)
################################## Constants #################################




################################# Main Methods ###############################
<#
.SYNOPSIS
Method called at each launch of Powershell

.DESCRIPTION
Sets up things needed in each console session, asside from prompt
#>
function Start-Up{
    if(Test-Path ~\.last) {
        (Get-Content ~\.last) | set-location
       rm ~\.last
    }

    # Makes git diff work
    $env:TERM = "msys"
}

<#
.SYNOPSIS
Generates the prompt before each line in the console
#>
function Prompt { 

    $realLASTEXITCODE = $LASTEXITCODE
    $gitStatus = Get-GitStatus
    $gitColor = "green"
    if($gitStatus -and ($gitStatus.HasIndex -or $gitStatus.HasUntracked -or $gitStatus.HasWorking)) { $gitColor = "yellow"}
    if($gitStatus -and -not ($gitStatus.HasIndex -or $gitStatus.HasUntracked -or $gitStatus.HasWorking) -and ($gitStatus.AheadBy -gt 0)){ $gitColor = "cyan" }
    

    $drive = (get-drive (pwd).Path)
    $color = "gray"
    switch ($drive){
        "\\" { $color = "green" }
        "C:" { $color = "blue" }
        "~"  { $color = "blue"}
    }

    if(-not (Vanilla-Window)){ Write-Colors $color " "}
    Write-Colors $color "$drive"
    Write-Colors $color (shorten-path (pwd).Path)
    Write-Colors $color " "

    if(Vanilla-Window){
        if(-not $gitStatus) { Write-Host ">" -n }
    } else {
        if($gitStatus){
            Write-Host $FANCY_SPACER -f $colors[$color][1] -b $colors[$gitColor][1] -n
        } else {
            Write-Colors $color $FANCY_SPACER -invert -noB
        }
    }
    
    if($gitStatus) {
        if(Vanilla-Window){
            Write-Colors $gitColor "($($gitStatus.branch)) "
            Write-Host ">" -n
        } else {
            Write-Colors $gitColor " $GIT_BRANCH $($gitStatus.branch) "
            Write-Colors $gitColor $FANCY_SPACER -invert -noB    
        }
        
    }



    return " " 
} 
################################# Main Methods ###############################





################################ Helper Methods ##############################
function Write-Colors{
    param(
        [Parameter(Mandatory=$True)][string]$color,
        [string]$message,
        [switch]$newLine,
        [switch]$invert,
        [switch]$noBackground
    )

    if(-not $colors[$color]){
        throw "Not a valid color: $color"
    }

    $noBackground = ($noBackground -or (Vanilla-Window))

    $FG = 0
    $BG = 1
    if($invert){
        $FG = 1
        $BG = 0
    }


    if(-not ($noBackground)){
        Write-Host $message -ForegroundColor $colors[$color][$FG] -BackgroundColor $colors[$color][$BG] -NoNewline
    } else {
        Write-Host $message -ForegroundColor $colors[$color][$FG] -NoNewline
    }

    if($newLine) { Write-Host "" }
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

function Colors {
    Write-Host "INDIVIDUAL COLORS"
    [ConsoleColor].DeclaredMembers | Select Name | Where {$_.Name -ne "value__" } |% {Write-Host $_.Name -f $_.Name}

    Write-Host
    Write-Host "NAMED PAIRS"
    $colors.Keys | % {
        Write-Host  " $_ " -f $colors[$_][0] -b $colors[$_][1]
    }
}
################################ Helper Methods ##############################


Start-Up # Executes the Start-Up function, better encapsulation
Set-Alias subl "C:\Program Files\Sublime Text 3\sublime_text.exe"
