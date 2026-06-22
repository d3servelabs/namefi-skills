# namefi-skills

Agent skills for [Namefi](https://namefi.io) — register traditional domains as
NFTs and manage their DNS, from an AI agent or the command line.

## Skills

| Skill | What it's for |
|-------|---------------|
| [`skills/namefi-domain-api`](skills/namefi-domain-api/SKILL.md) | Drive the Namefi REST API directly with small `curl` helper scripts — register a domain, poll order status, and CRUD DNS records with an API key. |
| [`skills/namefi-mcp`](skills/namefi-mcp/SKILL.md) | Connect to the Namefi **MCP server** (`/mcp`, Streamable HTTP) so an MCP-capable client gets every `/v-next` operation as a tool. |

Both cover the same operations; pick REST/curl (`namefi-domain-api`) or MCP
(`namefi-mcp`) depending on your client.

## Prerequisites

- A Namefi API key — generate one at https://namefi.io/api-key (must belong to
  the wallet that owns the domain). Export it as `NAMEFI_API_KEY` or put it in a
  local `.env`.
- The REST scripts need `curl` and `jq`.

```bash
export NAMEFI_API_KEY=nfk_your_key
```

All endpoints use production (`https://api.namefi.io/v-next`).

## Reference

- Machine-readable agent guide: https://namefi.io/llms.txt
- OpenAPI: https://api.namefi.io/v-next/openapi/doc
