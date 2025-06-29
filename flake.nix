{
  description = "Serena MCP Server Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    serena-mcp = {
      url = "github:oraios/serena";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      uv2nix,
      pyproject-nix,
      pyproject-build-systems,
      serena-mcp,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {

      packages = forAllSystems (
        pkgs:
        let
          serena-mcp-patched = pkgs.applyPatches {
            name = "serena-mcp-patched";
            src = serena-mcp;
            patches = [
              ./fix-nix-config-file-path.patch
            ];
          };

          workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = serena-mcp-patched; };

          overlay = workspace.mkPyprojectOverlay {
            sourcePreference = "wheel";
          };

          python = pkgs.python311;

          util = pkgs.callPackages pyproject-nix.build.util { };

          pythonSet =
            (pkgs.callPackage pyproject-nix.build.packages {
              inherit python;
            }).overrideScope
              (
                nixpkgs.lib.composeManyExtensions [
                  pyproject-build-systems.overlays.default
                  overlay
                ]
              );
        in
        {
          default = util.mkApplication {
            venv = pythonSet.mkVirtualEnv "serena-mcp-venv" workspace.deps.default;
            package = pythonSet.serena;
          };
        }
      );

      apps = nixpkgs.lib.genAttrs systems (system: {
        index-project = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/index-project";
        };
        serena-mcp-server = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/serena-mcp-server";
        };
      });
    };
}
