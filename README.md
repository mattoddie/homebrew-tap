# mattoddie/tap

[Homebrew](https://brew.sh) formulas for the MCP servers by [@mattoddie](https://github.com/mattoddie), on macOS and Linux (Intel and Arm).

| Formula | Install | What it is |
|---|---|---|
| `unifi-mcp` | `brew install mattoddie/tap/unifi-mcp` | MCP server for [Ubiquiti UniFi Network](https://unifi-mcp.mattoddie.dev) |
| `proxmox-mcp` | `brew install mattoddie/tap/proxmox-mcp` | MCP server for [Proxmox VE](https://proxmox-mcp.mattoddie.dev) |
| `hive-mcp` | `brew install mattoddie/tap/hive-mcp` | MCP server for [Hive heating](https://hive-mcp.mattoddie.dev) |
| `octopus-mcp` | `brew install mattoddie/tap/octopus-mcp` | MCP server for [Octopus Energy](https://octopus-mcp.mattoddie.dev) |
| `crunch-mcp` | `brew install mattoddie/tap/crunch-mcp` | MCP server for [Crunch Accounting](https://crunch-mcp.mattoddie.dev) |
| `bluelink-mcp` | `brew install mattoddie/tap/bluelink-mcp` | MCP server for [Hyundai Bluelink and Kia Connect](https://bluelink-mcp.mattoddie.dev) |

Installing with the full name, as above, also tells Homebrew 6 to [trust](https://docs.brew.sh/Tap-Trust) that formula. To use short names such as `brew install unifi-mcp`, trust the formula with `brew trust --formula mattoddie/tap/unifi-mcp`, or the whole tap with `brew trust mattoddie/tap`.

A formula appears here after the first release of that server to include binaries. If `brew install` says a formula doesn't exist yet, use Docker or a Claude Desktop bundle from the server's releases page for now.

## Using a server

Each server reads its settings from environment variables and speaks MCP over stdio by default. Point your MCP client at the installed binary, which `brew --prefix` locates, for example in Claude Code:

```sh
claude mcp add unifi --env UNIFI_URL=https://192.168.1.1 --env UNIFI_API_KEY=... \
  --env UNIFI_TLS_FINGERPRINT=... -- "$(brew --prefix)/bin/unifi-mcp"
```

Each server's docs list its settings, under *Connecting MCP clients → Without Docker*.

`brew upgrade` picks up new versions.

## How it works

The Go servers' formulas install the prebuilt binaries attached to each GitHub release, so you don't need Go. bluelink-mcp is written in Python: its formula installs the release's wheel into a private virtualenv with Homebrew's Python, with every dependency pinned by the release's hash-locked requirements file and installed from wheels, so nothing compiles. Homebrew downloads them itself, so macOS doesn't block them as browser downloads.

An [hourly workflow](.github/workflows/update.yml) checks each server's latest stable release. For a new one, it:

1. downloads the release's macOS and Linux archives (or the wheel and requirements file) and `SHA256SUMS`
2. checks each file against `SHA256SUMS` and its signed build provenance, which must come from that server's release workflow
3. regenerates the formula with [`scripts/update-formulas.sh`](scripts/update-formulas.sh)
4. installs and tests it on macOS and Linux
5. pushes it to `main`

Pre-releases aren't published here.

Don't edit the formulas by hand, because the next update overwrites them. Change the generator instead.

## License

[MIT](LICENSE)
