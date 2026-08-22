[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegistrationToken
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$workDir = 'C:\AVD\AgentInstall'
New-Item -Path $workDir -ItemType Directory -Force | Out-Null
Set-Location $workDir

$agentUrl = 'https://go.microsoft.com/fwlink/?linkid=2310011'
$bootloaderUrl = 'https://go.microsoft.com/fwlink/?linkid=2311028'

function Download-Installer {
    param([string]$Uri, [string]$Path)
    Invoke-WebRequest -Uri $Uri -UseBasicParsing -OutFile $Path
    Unblock-File -Path $Path
}

$agentPath = Join-Path $workDir 'RDAgent.msi'
$bootloaderPath = Join-Path $workDir 'RDAgentBootLoader.msi'

try {
    $agentInstalled = Get-Service -Name 'RDAgentBootLoader' -ErrorAction SilentlyContinue
    if (-not $agentInstalled) {
        Download-Installer -Uri $agentUrl -Path $agentPath
        $arguments = @('/i', $agentPath, '/quiet', '/norestart', "REGISTRATIONTOKEN=$RegistrationToken")
        $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            throw "AVD Agent installation failed with MSI exit code $($process.ExitCode)."
        }
    }
    else {
        # Refresh the host-pool registration token when Terraform rotates it.
        $agentKey = 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent'
        if (Test-Path $agentKey) {
            Set-ItemProperty -Path $agentKey -Name 'IsRegistered' -Value 0 -Force
            Set-ItemProperty -Path $agentKey -Name 'RegistrationToken' -Value $RegistrationToken -Force
            Restart-Service -Name 'RDAgentBootLoader' -Force
            Start-Sleep -Seconds 10
        }
    }

    if (-not (Get-Service -Name 'RDAgentBootLoader' -ErrorAction SilentlyContinue)) {
        Download-Installer -Uri $bootloaderUrl -Path $bootloaderPath
        $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/i', $bootloaderPath, '/quiet', '/norestart') -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            throw "AVD Agent Boot Loader installation failed with MSI exit code $($process.ExitCode)."
        }
    }

    $service = Get-Service -Name 'RDAgentBootLoader' -ErrorAction Stop
    Write-Output "RDAgentBootLoader service state: $($service.Status)"
    Write-Output 'Azure Virtual Desktop Agent installation completed. A reboot is intentionally not performed by this script.'
}
finally {
    Remove-Item -Path $agentPath, $bootloaderPath -Force -ErrorAction SilentlyContinue
}
