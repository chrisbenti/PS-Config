function reload{
    $process = get-process | ?{$_.ID -eq $pid}
    if($process.MainWindowTitle.Equals("")){
        # Console
        start "C:\Program Files (x86)\Console2\Console.exe"
    } else {
        # Powershell 
        start "powershell.exe"
    }
    $process | kill

}

function sync{
    $Start = Get-Location
    $PowerShellConfig = "c:$($env:HOMEPATH)\Documents\WindowsPowershell"
    $ConsoleConfig = "c:$($env:HOMEPATH)\Application Data\Console"
    $Reload = $True

    $LookAt = (
            ("Console2 Configuration", $ConsoleConfig),
            ("Powershell Configuration", $PowerShellConfig)
        )


    $LookAt | % {
        Set-Location $_[1]
        $status = (gst)[-1]
        $pull = ""
        if($status.Contains("working directory clean")){
            Write-Host "No changes to: $($_[0])" -f Green 
            $pull = (git pull)
        } else {
            Write-Host "Syncing: $($_[0])" -f Red
            git add -u
            git add .
            Write-Host "Diff Message: " -f Blue
            git diff 
            git commit -m (Read-Host -Prompt "Commit Message")
            $pull = (git pull)
            git push
        }

        if (!$pull[0].GetType().Equals([System.Char]) -and $pull[0].Contains("Updating")){
            $Reload = $True
        }
    }

    Set-Location $Start

    Write-Host "All Synced!" -f Green
    if ($Reload) {reload}
}