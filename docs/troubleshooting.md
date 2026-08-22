# Troubleshooting

## Autoscale does not start or stop a VM

Check these items first:

- The scaling plan is enabled and assigned to the correct host pool.
- The schedule uses the intended Windows time zone.
- The Azure Virtual Desktop enterprise application has `Desktop Virtualization Power On Off Contributor` at subscription scope.
- No Azure Automation, Nerdio, or other scaling tool is controlling the same host pool.
- The VM does not have the `excludeFromScaling` maintenance tag.
- A host with a user session is not expected to stop while `ramp_down_stop_hosts_when = "ZeroSessions"`.

## Start VM on Connect does not work

Confirm:

- `start_vm_on_connect = true`.
- The Azure Virtual Desktop enterprise application has `Desktop Virtualization Power On Contributor` at subscription scope.
- The user is assigned to the desktop application group and has `Virtual Machine User Login` on the session hosts.
- The VM is deallocated rather than deleted or unavailable because of another fault.

## Terraform cannot create the autoscale role assignments

The deploying account needs permission to create role assignments at subscription scope. Use an account with Owner or User Access Administrator, or ask the subscription owner to create the two AVD service-principal assignments before deployment and import or remove the matching Terraform resources.

## Terraform

### `terraform validate` fails

Run:

```bash
terraform fmt -check -recursive
terraform init
terraform validate
```

If a provider schema changed, check the pinned AzureRM 4.81.0 documentation before changing resource arguments.

## AVD registration

Microsoft's current registration workflow requires the AVD Agent and Agent Boot Loader plus a valid host-pool registration key.

Check:

```powershell
Get-Service RDAgentBootLoader
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent'
```

If the host reports `INVALID_REGISTRATION_TOKEN` or `EXPIRED_MACHINE_TOKEN`, generate/rotate the registration key and rerun Terraform.

## Entra join

```powershell
dsregcmd /status
```

Confirm `AzureAdJoined : YES`.

If `AADLoginForWindows` fails, review:

```text
C:\WindowsAzure\Logs\Plugins\Microsoft.Azure.ActiveDirectory.AADLoginForWindows
```

## Azure Files / FSLogix

Check:

```powershell
Get-SmbConnection
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\AzureADAccount'
Get-ItemProperty 'HKLM:\SOFTWARE\FSLogix\Profiles'
```

Then verify the share:

```text
\\<storage-account>.file.core.windows.net\profiles
```

Port 445 must be reachable from the session host.

## Token lifetime

The repository rotates the registration key every 24 hours and sets the actual key expiry slightly before the rotation boundary. If you have a deployment window longer than that, run Terraform again to refresh the key before provisioning additional hosts.
