# Seven-day AVD Autoscale test plan

This test plan shows weekday capacity, weekend on-demand access, user-session protection, FSLogix persistence, and the final cost comparison.

You don't need to watch the portal all day. Check the environment shortly before and after each phase change and record the result.

## Before Monday

1. Deploy from the VS Code terminal.
2. Complete the FSLogix post-deployment steps.
3. Confirm both session hosts show **Available**.
4. Confirm the weekday and weekend schedules are enabled.
5. Create a test file inside the test user's desktop or profile.
6. Sign out cleanly.

## Monday — ramp-up and peak

- Before 07:00, record the VM power states.
- After 07:00, confirm at least 50% of the hosts are available. With two hosts, this means one host.
- After 09:00, start test sessions and confirm Breadth First distribution when enough hosts are running.
- Confirm the test user's FSLogix profile attaches successfully.

## Tuesday — capacity threshold

- Start enough test sessions to raise used capacity above the configured threshold.
- Confirm Autoscale starts additional capacity when required.
- Record the session count and running-host count before and after the change.

With only one or two test users, the threshold might not start another host because each VM allows ten sessions. For a quick demonstration, temporarily lower `maximum_sessions_allowed` or the weekday capacity threshold, apply the change, run the test, then restore the default.

## Wednesday — active-session protection

- Keep one user signed in during ramp-down.
- Confirm the VM carrying that session is not stopped.
- Sign out and confirm the empty host can later be deallocated.

The lab uses `ZeroSessions` and does not force sign-out.

## Thursday — maintenance exclusion

- Add the tag name `excludeFromScaling` to one session-host VM.
- Confirm Autoscale does not start, stop, or change drain mode for that VM.
- Remove the tag after the test.

Do not exclude every host. Users can receive a no-resources-available error if Autoscale has no eligible VM to start.

## Friday — ramp-down and cost checkpoint

- Confirm ramp-down begins at 18:00 and uses Depth First.
- Confirm empty hosts move to drain mode and are deallocated.
- After 22:00, record how many hosts remain running.
- Capture the week's VM runtime from Azure Cost Management or VM metrics.

## Saturday — weekend on-demand access

- Confirm the weekend schedule is active.
- The minimum host percentage is 0%, so hosts can remain deallocated when nobody is working.
- Sign in through Windows App or the web client.
- Confirm Start VM on Connect starts a session host and the desktop becomes available.
- Confirm the FSLogix profile attaches and the earlier test file is present.
- Sign out cleanly.

## Sunday — repeat and close

- Repeat the on-demand connection once.
- Confirm an empty host returns to a deallocated state.
- Complete the cost table in `cost-analysis.md`.
- Save screenshots of the scaling plan, host states, successful login, and cost view.
- Destroy the lab if it is no longer needed.

## Evidence to keep for the portfolio

- Terraform plan summary with no secrets visible.
- Scaling-plan weekday and weekend schedules.
- Session hosts showing running and deallocated states.
- Start VM on Connect test result.
- FSLogix profile VHDX and profile-persistence result.
- Maintenance exclusion-tag result.
- VM-hours baseline and observed reduction.
- Final architecture diagram.

## Final pass criteria

- Every day is covered by exactly one schedule.
- Weekday ramp-up provides initial capacity.
- Capacity increases only when required.
- Active sessions are not interrupted.
- Empty hosts are deallocated during ramp-down/off-peak.
- Weekend access works through Start VM on Connect.
- The user profile follows the session across hosts.
- The observed cost report separates compute, disks, and profile storage.
