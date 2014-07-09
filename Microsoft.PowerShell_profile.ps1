##############################################################################
############################### Module Imports ###############################
##############################################################################
Import-Module -Name PsGet
Import-Module -Name PSUrl
Import-Module -Name Aliases
Import-Module -Name PowerTab
Import-Module -Name SyncMeUp
Import-Module -Name Work -ErrorAction SilentlyContinue
Import-Module -Name posh-git -ErrorAction SilentlyContinue
Import-Module -Name posh-hg -ErrorAction SilentlyContinue
Import-Module -Name posh-svn -ErrorAction SilentlyContinue
##############################################################################
############################### Module Imports ###############################
##############################################################################





##############################################################################
################################## Constants #################################
##############################################################################
$FANCY_SPACER = [char]11136
$GIT_BRANCH = [char]11104
$FANCY_X = [char]10008

$DRIVE_DEFAULT_COLOR = "gray"
$GIT_COLOR_DEFAULT = "green"

$colors = @{}
$colors["blue"] = ([ConsoleColor]::Cyan, [ConsoleColor]::DarkBlue)
$colors["green"] = ([ConsoleColor]::Green, [ConsoleColor]::DarkGreen)
$colors["cyan"] = ([ConsoleColor]::Cyan, [ConsoleColor]::DarkCyan)
$colors["red"] = ([ConsoleColor]::Red, [ConsoleColor]::DarkRed)
$colors["magenta"] = ([ConsoleColor]::Magenta, [ConsoleColor]::DarkMagenta)
$colors["yellow"] = ([ConsoleColor]::Yellow, [ConsoleColor]::DarkYellow)
$colors["gray"] = ([ConsoleColor]::White, [ConsoleColor]::DarkGray)
##############################################################################
################################## Constants #################################
##############################################################################





##############################################################################
################################# Main Methods ###############################
##############################################################################
<#
.SYNOPSIS
Method called at each launch of Powershell

.DESCRIPTION
Sets up things needed in each console session, asside from prompt
#>
function Start-Up{
    if(Test-Path -Path ~\.last) {
        (Get-Content -Path ~\.last) | set-location
       Remove-Item -Path ~\.last
    }

    # Makes git diff work
    $env:TERM = "msys"
    
    Try {
        Start-SshAgent -Quiet
    } Catch {} #Don't complain if the ssh agent isn't there
}

$driveColor = $DRIVE_DEFAULT_COLOR

<#
.SYNOPSIS
Generates the prompt before each line in the console
#>
function Prompt { 
    $drive = (Get-Drive (Get-Location).Path)
    
    switch ($drive){
        "\\" { $driveColor = "magenta" }
        "C:" { $driveColor = "blue" }
        "~"  { $driveColor = "blue"}
    }

    $lastColor = $driveColor

    # PowerLine starts with a space
    if(-not (Vanilla-Window)){ Write-Colors $driveColor " "}

    # Writes the drive portion
    Write-Colors $driveColor "$drive"
    Write-Colors $driveColor (Shorten-Path (Get-Location).Path)
    Write-Colors $driveColor " "

    if(Vanilla-Window){ #use the builtin posh-output
        Write-VcsStatus
    } else { #get ~fancy~
        $status = $false;
        Try {
            $status = Get-GitStatus;
        } Catch {} #Yes.
        if (!$status) {
            Try {
                $status = Get-HgStatus;
            } Catch {}
        }
        if (!$status) {
            Try {
                $status = Get-SvnStatus;
            } Catch {}
        }
        if ($status) {
            $lastColor = Write-Fancy-Vcs-Branches($status);
        }
    }

    # Writes the postfix to the prompt
    if(Vanilla-Window) { 
        Write-Host -Object ">" -n 
    } else {
        Write-Colors $lastColor $FANCY_SPACER -invert -noB 
    }

    return " " 
} 
##############################################################################
################################# Main Methods ###############################
##############################################################################




##############################################################################
################################ Helper Methods ##############################
##############################################################################
function Write-Fancy-Vcs-Branches($status) {
    if ($status) {
        $color = $GIT_COLOR_DEFAULT

        # Determine Colors
        $localChanges = ($status.HasIndex -or $status.HasUntracked -or $status.HasWorking); #Git flags
        $localChanges = $localChanges -or (($status.Untracked -gt 0) -or ($status.Added -gt 0) -or ($status.Modified -gt 0) -or ($status.Deleted -gt 0) -or ($status.Renamed -gt 0)); #hg/svn flags

        if($localChanges) { $color = "yellow"}
        if(-not ($localChanges) -and ($status.AheadBy -gt 0)){ $color = "cyan" } #only affects git     
        
        Write-Host -Object $FANCY_SPACER -ForegroundColor $colors[$driveColor][1] -BackgroundColor $colors[$color][1] -NoNewline
        Write-Colors $color " $GIT_BRANCH $($status.Branch) "
        return $color
    }
}

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
        Write-Host -Object $message -ForegroundColor $colors[$color][$FG] -BackgroundColor $colors[$color][$BG] -NoNewline
    } else {
        Write-Host -Object $message -ForegroundColor $colors[$color][$FG] -NoNewline
    }

    if($newLine) { Write-Host -Object "" }
}



function Vanilla-Window{
    if($env:PROMPT -or $env:ConEmuANSI){
        # Console
        return $false
    } else {
        # Powershell
        return $true
    }
}



function Get-Drive( [string] $path ) {
    if( $path.StartsWith( $HOME ) ) {
        return "~"
    } elseif( $path.StartsWith( "Microsoft.PowerShell.Core" ) ){
        return "\\"
    } else {
        return $path.split( "\" )[0]
    }
}


function Shorten-Path([string] $path) { 
    $loc = $path.Replace($HOME, '~') 


    # remove prefix for UNC paths 
    $loc = $loc -replace '^[^:]+::', '' 


    $drive = Get-Drive (Get-Location).Path
    $loc = $loc.TrimStart( $drive )


    # make path shorter like tabs in Vim, 
    # handle paths starting with \\ and . correctly 
    return ($loc -replace '\\(\.?)([^\\]{3})[^\\]*(?=\\)','\$1$2') 
}


function Colors {
    Write-Host -Object "INDIVIDUAL COLORS"
    [ConsoleColor].DeclaredMembers | Select-Object -Property Name `
        | Where-Object {$_.Name -ne "value__" } `
        | ForEach-Object {
            Write-Host -Object $_.Name -ForegroundColor $_.Name
        }

    Write-Host
    Write-Host -Object "NAMED PAIRS"
    $colors.Keys | ForEach-Object {
        Write-Host -Object " $_ " `
            -ForegroundColor $colors[$_][0] `
            -BackgroundColor $colors[$_][1]
    }
}
##############################################################################
################################ Helper Methods ##############################
##############################################################################





Start-Up # Executes the Start-Up function, better encapsulation
Set-Alias -Name subl -Value "C:\Program Files\Sublime Text 3\sublime_text.exe"