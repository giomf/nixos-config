{ inputs, ... }:
{
  flake-file.inputs = {
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
  };

  flake.modules.homeManager.claude-code =
    { pkgs, lib, ... }:
    let
      statusline = pkgs.writeShellApplication {
        name = "claude-statusline";
        runtimeInputs = [ pkgs.jq ];
        text = builtins.readFile ./statusline.sh;
      };
    in
    {
      programs.claude-code = {
        enable = true;
        # Node on claude's PATH only, for plugin hooks
        package = pkgs.symlinkJoin {
          name = "claude-code-${pkgs.claude-code.version}";
          paths = [ pkgs.claude-code ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/claude --prefix PATH : ${lib.makeBinPath [ pkgs.nodejs-slim ]}
          '';
          inherit (pkgs.claude-code) meta;
        };
        # Read-only settings.json: change theme, plugins etc. here, not via /config or /plugin.
        settings = {
          theme = "dark";
          # lobaro marketplace itself comes from the org's managed settings
          enabledPlugins = {
            "lobaro-firmware@lobaro" = true;
            # Marketplace install, not programs.claude-code.plugins: that links per
            # file and Claude Code rejects hooks resolving outside the plugin dir.
            # https://github.com/nix-community/home-manager/issues/9906
            "ponytail@ponytail" = true;
          };
          extraKnownMarketplaces.ponytail.source = {
            source = "github";
            repo = "DietrichGebert/ponytail";
          };
          # No Co-Authored-By / "Generated with Claude Code" lines
          attribution = {
            commit = "";
            pr = "";
          };
          statusLine = {
            type = "command";
            command = lib.getExe statusline;
          };
        };
        # codegraph comes from the project dev shell (patched there), not installed globally
        mcpServers.codegraph = {
          command = "codegraph";
          args = [
            "serve"
            "--mcp"
          ];
        };
        skills = {
          grilling = "${inputs.mattpocock-skills}/skills/productivity/grilling";
          git = ./skills/git;
          cpp-review = ./skills/cpp-review;
        };
      };
    };
}
