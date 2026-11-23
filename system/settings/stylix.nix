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
        base16Scheme = "${pkgs.base16-schemes}/share/themes/precious-dark-eleven.yaml";
        fonts = {
          # rio ignores fontconfig, so it needs the name here; installed and set as system default in font.nix
          monospace.name = "FiraCode Nerd Font Mono";
          # Points; rio gets pt * 4/3 px, so this is rio's old size 15
          sizes.terminal = 11.25;
        };
      };

      home-manager.sharedModules = [
        (
          { config, ... }:
          {
            stylix.targets = {
              bat.enable = true;
              btop.enable = true;
              # Browser UI via the Firefox Color extension; pages stay with Dark Reader
              firefox = {
                enable = true;
                profileNames = [ "guif" ];
                # Keep Firefox on the fontconfig defaults from font.nix
                fonts.enable = false;
                colorTheme.enable = true;
                # Accent base0A like COSMIC and Thunderbird instead of blue base0D
                colors.override = with config.lib.stylix.colors; {
                  base0D-rgb-r = base0A-rgb-r;
                  base0D-rgb-g = base0A-rgb-g;
                  base0D-rgb-b = base0A-rgb-b;
                };
              };
              rio.enable = true;
              yazi.enable = true;
            };
          }
        )
      ];
    };
}
