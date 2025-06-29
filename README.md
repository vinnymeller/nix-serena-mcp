# Serena MCP Flake

## NOTE: doesn't work quite yet

Serena seems to do lots of not totally nix friendly stuff. Currently having issues with `setup_runtime_dependencies` methods

Nix flake for the [Serena MCP Server](https://github.com/oraios/serena).

The Serena configuration file, in this Nix version (see patch), will be located at `$HOME/.config/serena/serena_config.yml`.

# Usage

See the official Serena repo above for how to use and configure the server.

You can either install the default package from this flake which will provide `serena-mcp-server` and `index-project` binaries, or you can use set up your MCP configuration like:

```json
{
  "mcpServers": {
    "serena": {
      "command": "nix",
      "args": [
        "run",
        "github:vinnymeller/nix-serena-mcp#serena-mcp-server",
        "--",
        "--context",
        "ide-assistant",
        "--project",
        "$(pwd)"
      ]
    }
  }
}
```

You can call `nix run github:vinnymeller/nix-serena-mcp#index-project` for the index project command.


TODOS (busy next few days, in case you happen to see this before then):

- [ ] Add automatic nightly updates
- [ ] Module(s)?
- [ ] Improve config file location customization & see if upstream is interested
