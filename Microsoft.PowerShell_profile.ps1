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

$SHORT_FOLDER_NAME_SIZE = 3

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
    
    if(Get-Module Posh-Git) {
        Start-SshAgent -Quiet
    }
}

$driveColor = $DRIVE_DEFAULT_COLOR

<#
.SYNOPSIS
Generates the prompt before each line in the console
#>
function Prompt { 
    $drive = (Get-Drive (Get-Location).Path)
    
    switch -wildcard ($drive){
        "C:\" { $driveColor = "blue" }
        "~\"  { $driveColor = "blue"}
        "\\*" { $driveColor = "magenta" }
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
        $status = Get-VCSStatus
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

function Get-VCSStatus{
    $status = $false
    $vcs_systems = @{"posh-git"  = "Get-GitStatus"; 
                     "posh-hg"   = "Get-HgStatus";
                     "posh-svn"  = "Get-SvnStatus"
                    }

    $vcs_systems.Keys | ForEach-Object {
        if((Get-Module -Name $_).Count -gt 0){
            $status = (Invoke-Expression -Command ($vcs_systems[$_]))       
        }   
    }
    return $status
}


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

function Get-Home 
{
    return $HOME;
}

function Get-Drive( [string] $path ) {
    $homedir = Get-Home;
    if( $path.StartsWith( $homedir ) ) {
        return "~\"
    } elseif( $path.StartsWith( "Microsoft.PowerShell.Core" ) ){
        $parts = $path.Replace("Microsoft.PowerShell.Core\FileSystem::\\","").Split("\")
        return "\\$($parts[0])\$($parts[1])"
    } else {
        return (Get-Item $path).Root
    }
}

function Is-VCSRoot( $dir ) {
    return (Get-ChildItem -Path $dir.FullName -force .git) `
       -Or (Get-ChildItem -Path $dir.FullName -force .hg) `
       -Or (Get-ChildItem -Path $dir.FullName -force .svn) `
}

function Shorten-Path([string] $path) { 

    $result = @()
    $dir = Get-Item $path

    while( ($dir.Parent) -And ($dir.FullName -ne $HOME) ) {

        if( (Is-VCSRoot $dir) -Or ($result.length -eq 0) ) {
            $result = ,$dir.Name + $result
        } else {
            $result = ,$dir.Name.Substring(0, $SHORT_FOLDER_NAME_SIZE) + $result
        }

        $dir = $dir.Parent
    }

    return $result -join "\"
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