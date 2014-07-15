Import-Module Pester
Set-StrictMode -Version Latest
Import-Module agent-api -ErrorAction SilentlyContinue

$Results = Invoke-Pester -PassThru .\Tests
if (Get-Command "Add-AppveyorTest" -ErrorAction SilentlyContinue) {
    foreach($test in $Results.TestResult) {
        $outcome = "Failed";
        if ($test.Passed) {
            $outcome = "Passed";
        }
        Add-AppveyorTest -Name $test.Name -Outcome $outcome -Duration $test.Time.TotalMilliseconds -ErrorMessage $test.FailureMessage -ErrorStackTrace $test.StackTrace
    }
} else {}