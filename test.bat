@Powershell -NonInteractive -NoProfile -ExecutionPolicy Bypass -Command ^
"Import-Module Pester;  Set-StrictMode -Version Latest; Invoke-Pester -EnableExit .\Tests"