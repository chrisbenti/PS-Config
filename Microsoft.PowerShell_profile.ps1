Import-Module PsGet
Import-Module PSUrl
Import-Module Aliases


function CDScripts {set-location C:\Users\chbentiv\Documents\Scripts}
Set-Alias s CDScripts

function CDNovaScripts {set-location \\novafs01\nova\Users\chbentiv\Scripts}
Set-Alias n CDNovaScripts

function CDProdStudFiles {set-location "C:\Users\chbentiv\Documents\Product Studio Files"}
Set-Alias p CDProdStudFiles

function temp {set-location "C:\Users\chbentiv\Desktop\temp"}


function prompt { 

    $realLASTEXITCODE = $LASTEXITCODE

    $drive = (get-drive (pwd).Path)

    $color = [ConsoleColor]::Cyan
    switch ($drive){
        "\\"    {$color = [ConsoleColor]::Green}   
    }

    write-host $drive -n -f $color
    write-host (shorten-path (pwd).Path) -n -f $color

    $LASTEXITCODE = $realLASTEXITCODE


    return " > " 
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