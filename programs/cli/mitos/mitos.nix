{ inputs, ... }:

{
  # TODO: drop input and use pkgs.mitos once NixOS/nixpkgs#576743 lands
  flake-file.inputs.mitos-pr = {
    url = "github:giomf/nixpkgs/mitos-0.1.1";
    flake = false;
  };

  flake.modules.homeManager.mitos =
    { pkgs, config, ... }:
    {
      home.packages = [
        (pkgs.callPackage "${inputs.mitos-pr}/pkgs/by-name/mi/mitos/package.nix" { })
      ];

      # Helix fork: own config.toml (format diverges), languages.toml still shared with helix
      xdg.configFile = {
        "mitos/config.toml".source = ./config.toml;
        "mitos/languages.toml".source = config.xdg.configFile."helix/languages.toml".source;
      };
    };
}
