function sync{
    $Start = Get-Location
    $PowerShellConfig = "c:$($env:HOMEPATH)\Documents\WindowsPowershell"
    $ConsoleConfig = "c:$($env:HOMEPATH)\Application Data\Console"

    $LookAt = (
            ("Console2 Configuration", $ConsoleConfig),
            ("Powershell Configuration", $PowerShellConfig)
        )


    $LookAt | % {
        Set-Location $_[1]
        $status = (gst)[-1]
        if($status.Contains("working directory clean")){
            Write-Host "No local $($_[0])" -f Green 
            git pull
        } else {
            Write-Host "Syncing $($_[0])" -f Red
            git add -u
            git add .
            Write-Host "Diff Message: " -f Blue
            git diff 
            git commit -m (Read-Host -Prompt "Commit Message")
            git pull
            git push
        }
    }

    Set-Location $Start

    Write-Host "All Synced!" -f Green
}