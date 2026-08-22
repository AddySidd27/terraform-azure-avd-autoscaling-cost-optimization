# Cost analysis

Use this page to record the result of an Autoscale test. Prices are intentionally not hard-coded because Azure rates vary by region, date, agreement, and currency.

## 1. Establish the baseline

For the default two-host lab running continuously:

```text
2 hosts × 24 hours × 30 days = 1,440 VM-hours per month
```

## 2. Estimate the schedule

For a seven-day example, first record the observed weekday and weekend running hours separately:

```text
Monthly scheduled VM-hours =
  (weekday VM-hours × average weekdays per month)
  + (weekend VM-hours × average weekend days per month)
```

If two hosts average 12 hours on weekdays and four hours on weekend days:

```text
Weekdays: 2 × 12 × 22 = 528 VM-hours
Weekends: 2 × 4 × 8 = 64 VM-hours
Scheduled total: 592 VM-hours
Maximum reduction: (1,440 - 592) / 1,440 × 100 = 58.9%
```

This is a planning estimate, not a guaranteed saving. Autoscale can start more capacity when utilization crosses a threshold.

## 3. Include the remaining costs

Deallocation stops VM compute charges, but include:

- Managed OS disks.
- Azure Files capacity and transactions.
- Log Analytics ingestion and retention if monitoring is enabled.
- Backup, snapshots, Private Endpoints, firewall, and outbound transfer if added.
- Applicable AVD licensing.

## 4. Record the test

| Item | Result |
|---|---|
| Region | |
| VM size and count | |
| Test dates | |
| Baseline VM-hours | |
| Autoscaled VM-hours | |
| VM-hours avoided | |
| Estimated compute reduction | |
| Azure Cost Management result | |
| User-impact notes | |

## 5. Validate in Azure

1. Open **Cost Management + Billing**.
2. Select **Cost analysis**.
3. Filter to resource group `rg-avd-dev`.
4. Group by **Resource** or **Meter**.
5. Compare a representative always-on period with an autoscaled period.
6. Separate compute from disks and storage before reporting the result.

Use the Azure Pricing Calculator for a forward-looking estimate and Azure Cost Management for observed cost.
