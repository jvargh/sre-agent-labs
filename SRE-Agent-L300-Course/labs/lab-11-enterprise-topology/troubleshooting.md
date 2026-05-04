# Lab 11 — Enterprise Topology: Troubleshooting

## Common Issues

### Consent URL Not Generated

- **Cause:** The primary tenant may not have the cross-tenant connector feature enabled.
- **Fix:** Verify the agent's SKU supports cross-tenant connectors. Check [Cross-Tenant Access](https://sre.azure.com/docs/capabilities/cross-tenant-access) for supported configurations.

### Entra Admin Denies Consent

- **Cause:** Insufficient admin permissions in the remote tenant.
- **Fix:** The admin needs Global Administrator or Cloud Application Administrator role. If they have a lesser role, escalate to a Global Admin.

### Connector Stuck on "Pending Consent"

- **Cause:** The consent URL was not opened in the correct tenant context.
- **Fix:** The Entra admin must open the URL while signed into the **remote** tenant (not the primary). Use an InPrivate/incognito window to avoid session confusion.

### Connection Failed After Consent

- **Cause:** UAMI role assignment missing in remote tenant, or NSG blocks traffic.
- **Fix:** In the remote tenant, verify the primary UAMI has been granted the appropriate role (e.g., Log Analytics Reader). Check NSG rules. Role assignment propagation can take up to 5 minutes.

### Query Returns Empty Results from Remote Tenant

- **Cause:** Remote workspace has no data, or the time range is too narrow.
- **Fix:** Verify the remote workspace has data by querying directly in the Azure Portal. Widen the time range.

### Private DNS Resolution Fails

- **Cause:** Private DNS zone not linked to the agent's VNET.
- **Fix:** Ensure the private DNS zone for the remote resource is linked to the VNET where the agent resides. Check with `nslookup` from within the agent's network.

### Fallback Activation

If either prerequisite is missing (second subscription or Entra admin), immediately switch to the lecture-only variant:
1. Announce the fallback to the attendee
2. Follow the Lecture-Only Fallback section in the lab guide
3. Document the activation in D16 (operations runbook)

## Escalation

If issues persist, escalate to:
1. Entra admin (for consent/identity issues)
2. Trainer (for network/topology issues)
3. Include: both tenant IDs, connector status, error messages, NSG rules
