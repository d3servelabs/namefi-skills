---
name: namefi-mcp
description: Connect to and use the Namefi MCP (Model Context Protocol) server to register domains, manage DNS, search availability, and run outbound lead-finding — every Namefi /v-next API operation exposed as MCP tools over Streamable HTTP. Use when an agent (Claude Code, Cursor, Codex, etc.) should drive Namefi through MCP instead of raw REST/curl. Requires a Namefi API key for authenticated operations.
---

# Namefi MCP

The Namefi backend exposes its entire `/v-next` API as MCP tools at `/mcp` over the
**Streamable HTTP** transport. One tool is generated per oRPC procedure, so the MCP
surface mirrors the REST API (and the `namefi-domain-api` skill in this repo) — search,
registration, DNS, domain config, outbound, balance, and EIP-712/SIWE auth helpers.

Prefer this skill when you want an MCP client to call Namefi tools directly. Prefer the
sibling `namefi-domain-api` skill when you want plain curl scripts.

## Endpoints

| Environment | MCP URL |
|-------------|---------|
| Production  | `https://api.namefi.io/mcp` |
| Dev / Astra | `https://backend.astra.namefi.io/mcp` |
| Local       | `http://localhost:3000/mcp` (see "Run the server locally") |

> Availability: the `/mcp` endpoint ships with namefi-astra PR #4723. Until that deploys,
> use the Local option below.

## Add the server to a client

**Claude Code**
```bash
claude mcp add --transport http namefi https://backend.astra.namefi.io/mcp
```

**Generic MCP client config (`mcp.json`)**
```json
{
  "mcpServers": {
    "namefi": {
      "type": "http",
      "url": "https://backend.astra.namefi.io/mcp"
    }
  }
}
```

Then list tools to confirm the connection (≈46 tools expected).

## Authentication

Get an API key at https://namefi.io/api-key (the key must belong to the wallet that owns
the domain). Read-only tools need no auth; everything that mutates or reads user data does.

**Auth headers go in the tool call's `headers` argument**, not the transport request — each
tool takes a wrapper object `{ headers, body }`, and per-tool auth is resolved from
`headers`. For a plain API key:

```jsonc
{
  "headers": { "x-api-key": "nfk_YOUR_KEY" },
  "body": { "payload": { /* the procedure input */ } }
}
```

- Read-only tools (`checkAvailability`, `getDnsRecords`, `isDomainParked`, …) can omit `headers`.
- EIP-712 / SIWE signing: put the signer/signature/type headers (and a signed envelope in
  `body`) in the same `headers` object — each tool's description documents the exact fields.
- Per-IP rate limit: 60 requests/minute (same as the REST surface).

## Tool catalog (≈46 tools)

| Group | Tools |
|-------|-------|
| Search | `checkAvailability`, `checkBulkAvailability`, `getSuggestions` |
| Registration / orders | `registerDomain`, `registerWithRecords`, `registerDomainForTrial`, `registerDomainX402`, `registerDomainMPP`, `getUserOrders`, `getOrder`, `getOrderItems`, `getOrderPaymentMethodsDetails`, `getDomainsAvailableForTrial` |
| DNS records | `getDnsRecords`, `createDnsRecord`, `updateDnsRecord`, `deleteDnsRecord`, `batchCreateDnsRecords`, `batchUpdateDnsRecords`, `batchDeleteDnsRecords`, `parkDomain`, `toggleDomainParking`, `isDomainParked`, `toggleForwarding`, `toggleAutoEns`, `toggleVercelAnyCastRecords` |
| Domain config | `toggleAutoRenew`, `getAutoRenew` |
| User / balance | `getUser`, `getUserPreferences`, `updateUserPreferences`, `getUserDomains`, `requestNfscFaucet`, `getBalance` |
| Outbound | `listOutboundRuns`, `startOutboundRun`, `getOutboundRun`, `listOutboundLeads`, `prepareOutboundOutreach` |
| Auth helpers | `getSiweNonce`, `prepareSiweMessage`, `verifySiweSignature`, `getAllowedChains`, `getEip712Domain`, `getAllEip712Types`, `getEip712TypesForMethod` |

## Example workflow (via MCP tools)

1. `checkAvailability` → `{ "body": { "payload": { "domain": "example.com" } } }` (no auth)
2. `registerDomain` → `{ "headers": { "x-api-key": "nfk_…" }, "body": { "payload": { "normalizedDomainName": "example.com", "durationInYears": 1 } } }` — returns an order `id`
3. `getOrder` → poll `{ "headers": { "x-api-key": "nfk_…" }, "body": { "payload": { "orderId": "<id>" } } }` until a terminal status
4. `createDnsRecord` → `{ "headers": { "x-api-key": "nfk_…" }, "body": { "payload": { "zoneName": "example.com", "type": "TXT", "name": "@", "rdata": "v=spf1 …", "ttl": 300 } } }`

Registration is asynchronous — always poll `getOrder` after `registerDomain`.

## Smoke test with curl (no client needed)

```bash
URL=https://backend.astra.namefi.io/mcp
# initialize
curl -s -X POST "$URL" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"0"}}}'
# list tools
curl -s -X POST "$URL" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
# call a read tool
curl -s -X POST "$URL" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"checkAvailability","arguments":{"body":{"payload":{"domain":"example.com"}}}}}'
```

Responses use SSE framing (`event: message` / `data: {…}`).

## Run the server locally (development)

From the `namefi-astra` checkout (the MCP server lives in `apps/backend`):

```bash
infisical run --env=dev -- env PORT=3000 ENVIRONMENT=local bun --cwd=apps/backend dev:internal
# → MCP at http://localhost:3000/mcp
```

A missing local Temporal server prints a harmless "Temporal search attributes validation
failed" warning at boot; it does not affect the HTTP/MCP endpoint.

## Notes

- The tool set mirrors `/v-next`; the human-readable API guide is https://namefi.io/llms.txt.
- x402 / MPP crypto-purchase HTTP-402 flows are separate REST routes, not MCP tools — but
  `registerDomainX402` / `registerDomainMPP` order tools are exposed here.
- Inspect tools interactively with `npx @modelcontextprotocol/inspector` (transport:
  Streamable HTTP, URL: the `/mcp` endpoint).
