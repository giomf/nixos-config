{ inputs, ... }:
{
  # Laptops only (unstable); servers on stable would need a release-branch input
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  flake.modules.nixos.stylix =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        # Opt in per app instead of theming everything at once
        autoEnable = false;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/github-dark.yaml";
        fonts = {
          monospace = {
            package = pkgs.cascadia-code;
            name = "Cascadia Code NF";
          };
          # Points; rio gets pt * 4/3 px, so this is rio's old size 15
          sizes.terminal = 11.25;
        };
      };

      # autoEnable = false skips the fontconfig target, so install the font ourselves (rio reads it via additional-dirs)
      fonts.packages = [ pkgs.cascadia-code ];

      home-manager.sharedModules = [
        {
          stylix.targets = {
            bat.enable = true;
            btop.enable = true;
            rio.enable = true;
            helix.enable = true;
            yazi.enable = true;
          };
        }
      ];
    };
}
