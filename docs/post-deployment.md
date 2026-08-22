# Post-deployment configuration

Complete these steps after `terraform apply`.

This guide matches the default setup: Microsoft Entra-joined Windows 11 session hosts, cloud-only users, Azure Files, Microsoft Entra Kerberos, and FSLogix.

## 1. Check the session hosts

```text
Azure Virtual Desktop
> Host pools
> avd-hp-avd-dev
> Session hosts
```

Both session hosts should show **Available**.

## 2. Add a test user to the AVD group

```text
Microsoft Entra ID
> Groups
> AVD_Users
> Members
> Add members
```

Add the user who will test the desktop.

Terraform already assigns `AVD_Users` these roles:

- **Desktop Virtualization User** on the desktop application group.
- **Virtual Machine User Login** on both session-host VMs.
- **Storage File Data SMB Share Contributor** on the `profiles` file share.

## 3. Check Microsoft Entra Kerberos

```text
Storage accounts
> <storage-account-name>
> File service
> Identity-based access
```

Confirm that **Microsoft Entra Kerberos** is enabled.

## 4. Grant consent to the storage application

```text
Microsoft Entra ID
> App registrations
> All applications
> [Storage Account] <storage-account-name>.file.core.windows.net
> API permissions
```

Select **Grant admin consent for your directory** and confirm.

Review Conditional Access policies. The storage application must be able to request a token silently during sign-in. An interactive MFA prompt can't be completed by the Kerberos flow.

## 5. Enable cloud-only group support

This step is required when the AVD users or groups are cloud-only.

Open the same storage application and select **Manifest**. Add this value to the existing `tags` array:

```json
"tags": [
  "kdc_enable_cloud_group_sids"
]
```

Do not remove existing tags. Select **Save**.

## 6. Check the file-share role

```text
Storage accounts
> <storage-account-name>
> File shares
> profiles
> Access Control (IAM)
> Role assignments
```

Confirm that `AVD_Users` has:

```text
Storage File Data SMB Share Contributor
```

Terraform creates this assignment.

## 7. Give the setup administrator access

From the same **Access Control (IAM)** page, add these roles to the administrator performing the setup:

```text
Storage File Data SMB Share Elevated Contributor
Storage File Data Privileged Contributor
```

Use an admin group in production. Remove temporary individual access after testing.

## 8. Set the FSLogix folder permissions

```text
Storage accounts
> <storage-account-name>
> File shares
> profiles
> Browse
> Manage access
```

Select **Add Entra user/group**, choose `AVD_Users`, and set:

```text
Permission: Modify
Applies to: This folder only
```

Next, select **Add Security ID** and enter:

```text
S-1-3-0
```

This appears as `CREATOR OWNER`. Set:

```text
Permission: Modify
Applies to: Subfolders and files only
```

These permissions allow users to create their own profile folder without giving them access to other users' profiles.

## 9. Restart and check the session hosts

Restart both session hosts after the Run Commands finish.

On each host, run:

```powershell
dsregcmd /status
Get-Service RDAgentBootLoader, RdAgent, frxsvc
Get-Service WinHttpAutoProxySvc, iphlpsvc
Get-ItemProperty 'HKLM:\SOFTWARE\FSLogix\Profiles'
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\AzureADAccount'
```

Confirm:

- `AzureAdJoined : YES`
- FSLogix `Enabled = 1`
- `VHDLocations` points to `\\<storage-account-name>.file.core.windows.net\profiles`
- `CloudKerberosTicketRetrievalEnabled = 1`
- `LoadCredKeyFromProfile = 1`
- The required services aren't disabled.

## 10. Test the user profile

1. Open the [Azure Virtual Desktop web client](https://client.wvd.microsoft.com/arm/webclient).
2. Sign in with a test user who is a member of `AVD_Users`.
3. Open the assigned desktop.
4. Create a folder on the desktop named `FSLogix-Test` and add a text file.
5. In the Azure portal, open the `profiles` file share.
6. Confirm that a user profile folder and `.vhdx` file were created.
7. In Windows, select **Start > user icon > Sign out**. Do not only close the browser.
8. Sign in again and confirm that the test folder and file are still present.
9. If both hosts are running, test the same user on the second host.

## Result

The setup is working when:

- Both session hosts are **Available**.
- The user can open the AVD desktop.
- A profile folder and VHDX are created in Azure Files.
- The test file remains after a full sign-out and sign-in.

## Cleanup

Stop or deallocate the session hosts when the lab isn't being used.

```powershell
terraform destroy
```

Destroying the storage account also deletes the FSLogix profiles.

## Microsoft documentation

- [Microsoft Entra Kerberos for Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable)
- [FSLogix profiles with Azure Files and Microsoft Entra ID](https://learn.microsoft.com/en-us/fslogix/how-to-configure-profile-container-entra-id-hybrid)
- [Azure Files directory and file permissions](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-configure-file-level-permissions)
