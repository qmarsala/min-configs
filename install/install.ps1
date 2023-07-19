InstallFromWingetBlock Git.Git

InstallFromWingetBlock Microsoft.DotNet.SDK.6 {
    Add-Content -Path $profile {
        Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            dotnet complete --position $cursorPosition $commandAst | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
}

Block "Add nuget.org source" {
    dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
} {
    dotnet nuget list source | sls nuget.org
}

InstallFromWingetBlock GitHub.cli {
    gh config set editor (git config core.editor)
    Add-Content -Path $profile {
        (gh completion -s powershell) -join "`n" | iex
    }
    if (!(Configured $forTest)) {
        gh auth login -w
    }
}

InstallFromWingetBlock Microsoft.VisualStudio.2022.Professional `
    "--passive --norestart --wait --includeRecommended --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb" `
{
    # https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids
    #   Microsoft.VisualStudio.Workload.ManagedDesktop    .NET desktop development
    #   Microsoft.VisualStudio.Workload.NetWeb            ASP.NET and web development
    # https://docs.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples#using---wait

    $vsInstallation = . "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -format json | ConvertFrom-Json
    $vsVersion = ($vsInstallation.installationVersion).Substring(0, 2)
} -NoUpdate

InstallFromWingetBlock NickeManarin.ScreenToGif {
    DeleteDesktopShortcut ScreenToGif
    Copy-Item2 $PSScriptRoot\..\programs\ScreenToGif.xaml $env:AppData\ScreenToGif\Settings.xaml
}

# Needed for fancy zones to improve workflow on my ultrawide
InstallFromWingetBlock Microsoft.PowerToys {
    Copy-Item2 $PSScriptRoot\..\programs\PowerToys.settings.json $env:LocalAppData\Microsoft\PowerToys\settings.json
    Copy-Item2 $PSScriptRoot\..\programs\PowerToys.VideoConference.settings.json "$env:LocalAppData\Microsoft\PowerToys\Video Conference\settings.json"
}

# Needed so I can use my own keyboard and mouse without having to move them every morning when I start working
InstallFromWingetBlock Microsoft.MouseWithoutBorders {
    Write-ManualStep "Configure new machine link"
}