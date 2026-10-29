---
name: namefi-mcp
description: Connect to and use the Namefi MCP (Model Context Protocol) server to register domains, manage DNS, search availability, and run outbound lead-finding — every Namefi /v-next API operation exposed as MCP tools over Streamable HTTP. Use when an agent (Claude Code, Cursor, Codex, etc.) should drive Namefi through MCP instead of raw REST. Requires a Namefi API key for authenticated operations.
---

# Namefi MCP

The Namefi backend exposes its entire `/v-next` API as MCP tools at `/mcp` over
the **Streamable HTTP** transport — one tool per oRPC procedure, so the MCP
surface mirrors the REST API (and the sibling `namefi-domain-api` skill): search,
registration, DNS, domain config, outbound, balance, and EIP-712/SIWE helpers.

Prefer this skill when your client speaks MCP. Prefer `namefi-domain-api` when you
want plain `curl` scripts.

## Endpoint

Connect at `https://api.namefi.io/mcp` over the Streamable HTTP transport.

## Add the server to a client

**Claude Code** — pass the API key as a connection header; it authorizes every
tool call (no need to repeat it per call):

```bash
claude mcp add --transport http namefi https://api.namefi.io/mcp \
  --header "x-api-key: nfk_YOUR_KEY"
```

**Generic MCP client config (`mcp.json`)**

```json
{
  "mcpServers": {
    "namefi": {
      "type": "http",
      "url": "https://api.namefi.io/mcp",
      "headers": { "x-api-key": "nfk_YOUR_KEY" }
    }
  }
}
```

Then list tools to confirm the connection (~46 tools expected).

## Authentication

`/mcp` authenticates every request, read-only tools included. Use one of two
methods:

- **OAuth.** Connect without a key. The client discovers the OAuth flow from the
  server's `WWW-Authenticate` challenge and opens the Namefi sign-in page.
- **API key.** Get a key at https://namefi.io/api-key (must belong to the wallet
  that owns the domain).

For availability and DNS lookups without sign-in, connect the public server at
`https://api.namefi.io/mcp-instant` instead.

- **Send the key as the `x-api-key` connection header** (above). It authorizes all
  tool calls, so the secret stays in client config — not in the model's context.
- Per-tool override: each tool also accepts a `headers` object in its arguments
  (`{ "headers": { "x-api-key": "…" }, "body": { "payload": { … } } }`); per-call
  headers take precedence over the connection header — useful for a different
  EIP-712 / SIWE signer per call. Each tool's description documents the fields.
- Per-IP rate limit: 60 requests/minute (same as the REST surface).

## Tool catalog (~46 tools)

| Group | Tools |
|-------|-------|
| Search | `checkAvailability`, `checkBulkAvailability`, `getSuggestions` |
| Registration / orders | `registerDomain`, `registerWithRecords`, `registerDomainForTrial`, `registerDomainX402`, `registerDomainMPP`, `getUserOrders`, `getOrder`, `getOrderItems`, `getOrderPaymentMethodsDetails`, `getDomainsAvailableForTrial` |
| DNS records | `getDnsRecords`, `createDnsRecord`, `updateDnsRecord`, `deleteDnsRecord`, `batchCreateDnsRecords`, `batchUpdateDnsRecords`, `batchDeleteDnsRecords`, `parkDomain`, `toggleDomainParking`, `isDomainParked`, `toggleForwarding`, `toggleAutoEns`, `toggleVercelAnyCastRecords` |
| Domain config | `toggleAutoRenew`, `getAutoRenew` |
| User / balance | `getUser`, `getUserPreferences`, `updateUserPreferences`, `getUserDomains`, `requestNfscFaucet`, `getBalance` |
| Outbound | `listOutboundRuns`, `startOutboundRun`, `getOutboundRun`, `listOutboundLeads`, `prepareOutboundOutreach` |
| Auth helpers | `getSiweNonce`, `prepareSiweMessage`, `verifySiweSignature`, `getAllowedChains`, `getEip712Domain`, `getAllEip712Types`, `getEip712TypesForMethod` |

## Tool input shape

Every tool takes a wrapper `{ headers?, body: { payload } }`:

```jsonc
// auth (API key or OAuth token) is on the connection — body is enough
{ "body": { "payload": { "domain": "example.com" } } }            // checkAvailability
{ "body": { "payload": { "normalizedDomainName": "example.com", "durationInYears": 1 } } } // registerDomain
```

Registration is asynchronous — after `registerDomain`, poll `getOrder` until a
terminal status.

## Smoke test with curl (no client needed)

```bash
URL=https://api.namefi.io/mcp
curl -s -X POST "$URL" -H "x-api-key: $NAMEFI_API_KEY" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
curl -s -X POST "$URL" -H "x-api-key: $NAMEFI_API_KEY" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"checkAvailability","arguments":{"body":{"payload":{"domain":"example.com"}}}}}'
```

Responses use SSE framing (`event: message` / `data: {…}`). Inspect interactively
with `npx @modelcontextprotocol/inspector` (transport: Streamable HTTP, URL: the
`/mcp` endpoint).

## Notes

- The tool set mirrors `/v-next`; the human-readable guide is https://namefi.io/llms.txt
  and the discovery descriptor is https://namefi.io/.well-known/mcp/servers.json.
- x402 / MPP crypto-purchase HTTP-402 flows are separate REST routes, not MCP
  tools — but the `registerDomainX402` / `registerDomainMPP` order tools are here.
