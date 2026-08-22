[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FslogixUncPath
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Service -Name 'frxsvc' -ErrorAction SilentlyContinue)) {
    throw 'FSLogix service (frxsvc) was not found. Use a supported AVD image with FSLogix preinstalled before deploying this configuration.'
}

$fslogixRoot = 'HKLM:\SOFTWARE\FSLogix\Profiles'
New-Item -Path $fslogixRoot -Force | Out-Null

New-ItemProperty -Path $fslogixRoot -Name 'Enabled' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $fslogixRoot -Name 'DeleteLocalProfileWhenVHDShouldApply' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $fslogixRoot -Name 'FlipFlopProfileDirectoryName' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $fslogixRoot -Name 'VolumeType' -PropertyType String -Value 'VHDX' -Force | Out-Null
New-ItemProperty -Path $fslogixRoot -Name 'VHDLocations' -PropertyType MultiString -Value @($FslogixUncPath) -Force | Out-Null

$kerberosRoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
New-Item -Path $kerberosRoot -Force | Out-Null
New-ItemProperty -Path $kerberosRoot -Name 'CloudKerberosTicketRetrievalEnabled' -PropertyType DWord -Value 1 -Force | Out-Null

$azureAdAccountRoot = 'HKLM:\SOFTWARE\Policies\Microsoft\AzureADAccount'
New-Item -Path $azureAdAccountRoot -Force | Out-Null
New-ItemProperty -Path $azureAdAccountRoot -Name 'LoadCredKeyFromProfile' -PropertyType DWord -Value 1 -Force | Out-Null

Write-Output "FSLogix configured with VHDLocations=$FslogixUncPath"
Write-Output 'Cloud Kerberos ticket retrieval enabled.'
Write-Output 'LoadCredKeyFromProfile enabled.'
Write-Output 'A reboot or policy refresh is required before the client-side Kerberos setting is effective.'
