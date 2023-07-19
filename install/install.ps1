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

    # Hide dynamic nodes in Solution Explorer
    Set-RegistryValue "HKCU:\Software\Microsoft\VisualStudio\$vsVersion.0_$($vsInstallation.instanceId)" -Name UseSolutionNavigatorGraphProvider -Value 0

    # Visual Studio > Help > Privacy > Privacy Settings... > Experience Improvement Program = No
    Set-RegistryValue "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VSCommon\$vsVersion.0\SQM" -Name OptIn -Value 0
} -NoUpdate

InstallFromWingetBlock 7zip.7zip {
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowDots -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowRealFileIcons -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name FullRow -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowSystemMenu -Value 1
    . "$env:ProgramFiles\7-Zip\7zFM.exe"
    Write-ManualStep "Tools >"
    Write-ManualStep "`tOptions >"
    Write-ManualStep "`t`t7-Zip >"
    Write-ManualStep "`t`t`tContext menu items > [only the following]"
    Write-ManualStep "`t`t`t`tOpen archive"
    Write-ManualStep "`t`t`t`tExtract Here"
    Write-ManualStep "`t`t`t`tExtract to <Folder>"
    Write-ManualStep "`t`t`t`tAdd to <Archive>.zip"
    Write-ManualStep "`t`t`t`tCRC SHA >"
    WaitWhileProcess 7zFM
}

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