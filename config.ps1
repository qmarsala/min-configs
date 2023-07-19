param([switch]$DryRun, [switch]$SkipBackup, [string]$Run)

. $PSScriptRoot\config-functions.ps1

$totalDuration = [Diagnostics.Stopwatch]::StartNew()

if (!(Test-Path $profile)) {
    New-Item $profile -Force
}

& $PSScriptRoot\powershell\config.ps1

. $profile
. $profile.AllUsersAllHosts
. $profile.AllUsersCurrentHost
. $profile.CurrentUserAllHosts
. $profile.CurrentUserCurrentHost
Update-WindowsTerminalSettings

Block "Git config" {
    git config --global --add include.path $PSScriptRoot\git\q.gitconfig
} {
    (git config --get-all --global include.path) -match "q\.gitconfig"
}

& $PSScriptRoot\install\install.ps1

Block "Blocks of interest this run" {
    $global:blocksOfInterest | % { Write-Output "`t$_" }
} {
    $global:blocksOfInterest.Length -eq 0
}

Write-Output "Total duration: $($totalDuration.Elapsed)"