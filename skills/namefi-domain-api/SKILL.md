---
name: namefi-domain-api
description: Interact with the Namefi API to register domains, manage DNS records, and check order status. Use when registering a domain, looking up DNS records, creating/updating/deleting DNS records, or checking the status of a Namefi order. Requires NAMEFI_API_KEY environment variable.
---

# Namefi Domain API

Manage domains and DNS via the Namefi REST API. Defaults to **production**
(`https://api.namefi.io/v-next`); override with `NAMEFI_API_BASE_URL` (e.g. the
dev backend `https://backend.astra.namefi.io/v-next`).

## Prerequisites

```bash
export NAMEFI_API_KEY=<your-api-key>            # or set in .env
export DOMAIN_NAME=example.com
# optional — defaults to prod:
export NAMEFI_API_BASE_URL=https://api.namefi.io/v-next
```

Account must have NFSC balance before registering. See [Managing Your Balance](https://docs.namefi.io/docs/03-getting-started/02-your-balance).

## Workflow

### 1. Register a domain

```bash
bash scripts/register-domain.sh example.com
# Prints: {"id":"<orderId>", ...}
```

### 2. Poll order status until terminal

```bash
bash scripts/check-order.sh <orderId>
# Terminal statuses: SUCCEEDED | FAILED | CANCELLED | PARTIALLY_COMPLETED
```

### 3. Manage DNS records

| Action | Script | Key args |
|--------|--------|----------|
| List records | `scripts/dns-get.sh` | `<zoneName>` |
| Create records | `scripts/dns-create.sh` | `<zoneName> <type> <name> <rdata> [ttl]` |
| Update a record | `scripts/dns-update.sh` | `<recordId> <zoneName> <type> <name> <rdata> [ttl]` |
| Delete records | `scripts/dns-delete.sh` | `<zoneName> <recordId> [recordId...]` |

## Scripts

**register-domain.sh** — Register a domain (1 year, async)
```bash
bash scripts/register-domain.sh example.com
```

**check-order.sh** — Get current order status
```bash
bash scripts/check-order.sh <orderId>
```

**dns-get.sh** — List all DNS records for a zone
```bash
bash scripts/dns-get.sh example.com
```

**dns-create.sh** — Add one DNS record
```bash
bash scripts/dns-create.sh example.com TXT @ "v=spf1 include:_spf.google.com ~all" 300
```

**dns-update.sh** — Update an existing record by ID
```bash
bash scripts/dns-update.sh <recordId> example.com TXT @ "new-value" 60
```

**dns-delete.sh** — Delete one or more records by ID
```bash
bash scripts/dns-delete.sh example.com <recordId1> <recordId2>
```

## Notes

- Orders are **asynchronous** — always poll `check-order.sh` after registering.
- `durationInYears` defaults to `1` (max 10).
- DNS record `name` uses `@` for the zone apex.
- All scripts read `NAMEFI_API_KEY` from the environment (or `.env` via `source .env`).

## Additional resources

- [Register a Domain guide](https://docs.namefi.io/docs/03-getting-started/01-your-first-domain)
- [OpenAPI reference](https://api.namefi.io/v-next/openapi/doc)
