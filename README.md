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

## Use this repo as a Claude plugin

This repo is also the **Namefi** plugin for Claude (`name: namefi`). The plugin
contains the two skills above and two MCP servers:

```
.claude-plugin/plugin.json   plugin manifest
.claude-plugin/icon.png      listing icon (512 x 512 PNG)
.mcp.json                    MCP servers the plugin connects
skills/                      the two skills
docs/connector-app/          directory carousel screenshots of the MCP App
```

| MCP server | URL | Sign-in |
|------------|-----|---------|
| `namefi-instant` | `https://api.namefi.io/mcp-simple` | None. Domain availability and DNS lookups only. |
| `namefi` | `https://api.namefi.io/mcp` | OAuth. Before you use its tools, run `/mcp` in Claude Code, select `namefi`, and sign in. |

To test the plugin locally, run `claude --plugin-dir .` in the repo root.

## The no-login connector shows a domain results card in Claude

`namefi-instant` (`https://api.namefi.io/mcp-simple`, directory listing
`namefi-io`) has an MCP App. When Claude calls `searchAvailability`, Claude web
and Desktop show the results as a card. The card source is in
[`namefi-astra/packages/mcp-apps`](https://github.com/d3servelabs/namefi-astra/tree/main/packages/mcp-apps).

These four screenshots are the directory carousel images. Each one is a real
Claude response from 2026-10-30 (UTC), cropped to the card. Availability is live
data, so the same prompt can show other results later.

| Screenshot | Prompt |
|------------|--------|
| ![Coffee subscription names, 3 available and 5 taken](docs/connector-app/carousel-1-brainstorm.png) | Brainstorm 8 names for a coffee subscription startup and check which .com domains are free. |
| ![brewloop.ai and brewloop.co selected, with Proceed to purchase](docs/connector-app/carousel-2-selected.png) | Check brewloop.com, brewloop.ai and brewloop.co for me. |
| ![lumen studio across 5 TLDs, 1 available](docs/connector-app/carousel-3-many-tlds.png) | Check "lumen studio" as .com, .io, .ai, .studio and .design. |
| ![Trail-running names across .com, .app and .run, 4 available](docs/connector-app/carousel-4-trail-names.png) | Suggest 3 short names for a trail-running app and check each as .com, .app and .run. |

## Data the plugin sends

- The MCP servers send tool calls only to `api.namefi.io`.
- The `namefi-domain-api` scripts send requests only to
  `https://api.namefi.io/v-next`, or to `NAMEFI_API_BASE_URL` when you set it.
  When you set `NAMEFI_API_BASE_URL`, that URL receives your API key. Set it
  only to a URL that you trust.
- The scripts read `NAMEFI_API_KEY` from your environment. When the variable is
  not set, the scripts read it from a `.env` file in the current directory. The
  scripts send the key only in the `x-api-key` header to the Namefi API.
- The plugin has no hooks and runs nothing in the background.

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
