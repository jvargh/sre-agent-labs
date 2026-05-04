# Lab 2 — Troubleshooting

| Symptom | Track | Likely Cause | Resolution |
|---------|-------|-------------|------------|
| Connector stays in `Connecting` state > 90 s | All | Credentials invalid or expired | Re-check credentials; for PagerDuty verify API token scopes; for ServiceNow wake the PDI first |
| No services appear in Knowledge Sources | PagerDuty | API token user not associated with the team | Verify user-team association in PagerDuty admin |
| Priority mapping is empty | ServiceNow | CMDB CI not created or assignment group missing | Create a CMDB CI for the sample workload; assign to a group |
| Connection fails with 403 | Azure Monitor | Agent UAMI missing `Monitoring Contributor` | Add the role assignment at the subscription scope in IAM |
| No incidents appear after 60 s | All | Synthetic incident not fired or platform webhook delay | Fire a test incident manually; wait up to 120 s for propagation |
| Quickstart plan not found | All | Already deleted in a previous session | Confirm the Incident Response Plans list is empty — this is correct |
| Double-routing of incidents after Lab 3 | All | Quickstart plan was not deleted | Return to Builder → Incident Response Plans and delete it now |
| PDI is sleeping / unreachable | ServiceNow | ServiceNow PDIs auto-sleep after inactivity | Log in to the PDI web UI to wake it; retry connection |
