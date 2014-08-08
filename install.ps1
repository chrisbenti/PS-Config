if (Test-Path (Split-Path -Parent $profile)) {
    Write-Host -ForegroundColor Red "You currently have a profile in place. This install script does not support merging. Please delete the directory or install by hand."
    Write-Host -ForegroundColor Red "(Profile is at $(Split-Path -Parent $profile))"
    return
}

if ((Get-Command git -ErrorAction SilentlyContinue).Count -eq 0) {
    Write-Host -ForegroundColor Red "Git needs to be installed to continue."
    return
}

if (-not (("Bypass", "Unrestricted") -contains (Get-ExecutionPolicy))){
    Write-Host "Your Execution Policy needs to be changed. Please hit enter at the UAC prompt. (Please hit enter to go to prompt)"
    Read-Host
    Start-Process -Verb runas -FilePath powershell -ArgumentList "set-executionpolicy bypass"
}


Write-Host -ForegroundColor Green "Installed and ready to go!"
