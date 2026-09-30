{ inputs, ... }:
{
  flake-file.inputs = {
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };
  };

  flake.modules.homeManager.claude-code =
    { pkgs, lib, ... }:
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
        skills = {
          grilling = "${inputs.mattpocock-skills}/skills/productivity/grilling";
        };
      };

      # Single symlink to the plugin source. Both `programs.claude-code.plugins` and
      # `.skills` link per entry/file, and Claude Code rejects hooks that resolve
      # outside the plugin dir.
      # https://github.com/nix-community/home-manager/issues/9906
      home.file.".claude/skills/ponytail".source = inputs.ponytail;
    };
}
