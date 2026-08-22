# Autoscale validation

Complete the FSLogix steps in `post-deployment.md` first, then use this guide to test power management.

## 1. Check the scaling plan

In the Azure portal:

1. Open **Azure Virtual Desktop**.
2. Select **Scaling plans**.
3. Open `avd-sp-avd-dev`.
4. Confirm the plan is enabled and assigned to `avd-hp-avd-dev`.
5. Open **Schedules** and confirm the time zone and four phase times.

## 2. Check the required roles

Open **Subscriptions > your subscription > Access control (IAM) > Role assignments**.

Search for the Azure Virtual Desktop enterprise application and confirm:

- `Desktop Virtualization Power On Off Contributor`
- `Desktop Virtualization Power On Contributor`

Both assignments must be at subscription scope.

## 3. Check the hosts before the test

Open the host pool and select **Session hosts**. Confirm both hosts are registered and their health status is **Available**.

Use Azure CLI to check VM power state:

```powershell
az vm get-instance-view `
  --resource-group rg-avd-dev `
  --name avdsh-01 `
  --query "instanceView.statuses[?starts_with(code,'PowerState/')].displayStatus" `
  --output tsv

az vm get-instance-view `
  --resource-group rg-avd-dev `
  --name avdsh-02 `
  --query "instanceView.statuses[?starts_with(code,'PowerState/')].displayStatus" `
  --output tsv
```

## 4. Run a short ramp-down test

1. Copy the complete `autoscale_schedules` value from `variables.tf` into `terraform.tfvars`.
2. In the schedule containing the current day, set `ramp_down_start_time` to 15-30 minutes ahead of the current time.
3. Set its `off_peak_start_time` later than ramp-down.
4. Run `terraform plan` and `terraform apply`.
5. Sign out of every AVD desktop. Do not only disconnect.
6. Watch **Host pool > Session hosts** and **Virtual machines**.

Expected result:

- Autoscale uses Depth First during ramp-down.
- An unused host can enter drain mode.
- A host with zero sessions is stopped and deallocated.
- The remaining capacity follows the configured thresholds.

Autoscale evaluation is not instant. Allow time for the service to evaluate the schedule and session state.

## 5. Test an active session safely

The default setting is:

```hcl
ramp_down_force_logoff_users = false
ramp_down_stop_hosts_when    = "ZeroSessions"
```

Keep one user signed in during ramp-down. Confirm that the VM carrying that session is not stopped. Sign out when the test is complete.

## 6. Test Start VM on Connect

1. Wait until all permitted hosts are deallocated during off-peak.
2. Confirm `start_vm_on_connect = true`.
3. Open Windows App or the AVD web client as an assigned test user.
4. Start the published desktop.

Expected result:

- A session-host VM starts.
- The connection can take longer while the VM boots.
- The host returns to **Available** and the user session opens.

If no VM starts, check the `Desktop Virtualization Power On Contributor` assignment at subscription scope.

## 7. Check Autoscale logs

For a full operations test, send the host-pool `Autoscale` diagnostic category to Log Analytics and open **Host pool > Insights > Autoscale**.

This base lab leaves Log Analytics optional so the core cost test remains small. Monitoring can be added as a follow-up module.

## 8. Restore the normal schedule

After a short test, remove the temporary `autoscale_schedules` override from `terraform.tfvars`, or return both schedules to the documented operating hours, then apply again:

```powershell
terraform plan -out=avd-autoscale.tfplan
terraform apply "avd-autoscale.tfplan"
```

## Pass criteria

- Scaling plan is enabled and associated with the correct pooled host pool.
- Required AVD service-principal roles exist at subscription scope.
- Ramp-up starts the minimum required capacity.
- Peak uses Breadth First.
- Ramp-down uses Depth First and does not stop a host with an active session.
- Unused hosts are deallocated.
- Start VM on Connect starts a host during off-peak.
- Users can reconnect and their FSLogix profile remains available.
