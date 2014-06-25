##############################################################################
############################### Module Imports ###############################
##############################################################################
Import-Module PsGet
Import-Module PSUrl
Import-Module Aliases
Import-Module PowerTab
Import-Module SyncMeUp
Import-Module Work -ErrorAction SilentlyContinue
Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module posh-hg -ErrorAction SilentlyContinue
Import-Module posh-svn -ErrorAction SilentlyContinue
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
    if(Test-Path ~\.last) {
        (Get-Content ~\.last) | set-location
       rm ~\.last
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
    $drive = (Get-Drive (pwd).Path)
    
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
    Write-Colors $driveColor (Shorten-Path (pwd).Path)
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
        Write-Host ">" -n 
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
        
        Write-Host $FANCY_SPACER -f $colors[$driveColor][1] -b $colors[$color][1] -n
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
        Write-Host $message -ForegroundColor $colors[$color][$FG] -BackgroundColor $colors[$color][$BG] -NoNewline
    } else {
        Write-Host $message -ForegroundColor $colors[$color][$FG] -NoNewline
    }

    if($newLine) { Write-Host "" }
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


    $drive = Get-Drive (pwd).Path
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
##############################################################################
################################ Helper Methods ##############################
##############################################################################





Start-Up # Executes the Start-Up function, better encapsulation
Set-Alias subl "C:\Program Files\Sublime Text 3\sublime_text.exe"