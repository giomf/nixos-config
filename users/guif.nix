{
  inputs,
  ...
}:
{

  flake.homeConfigurations = {
    guif = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    };
  };

  flake.modules.nixos.guif =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.fish.enable = true;
      users = {
        users = {
          guif = {
            extraGroups = [
              "wheel"
            ]
            ++ lib.optional config.services.openssh.enable "ssh"
            ++ lib.optional config.virtualisation.docker.enable "docker";
            group = "guif";
            initialHashedPassword = "$y$j9T$hHZ1NIxqNvPno5mkSDSjI1$PojSMDbnHYHcrrdaTw74w6tSlLIRvMCbCbaCiDpMx3.";
            isNormalUser = true;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw guif@glap"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHjWEdobmj/OH1tIi3us6tzxpqemUIreGwPjvEQc6AGj guif@wsl"
            ];
            shell = pkgs.fish;
          };
        };
        groups = {
          guif = { };
        }
        // lib.optionalAttrs config.services.openssh.enable {
          ssh = { };
        };
      };
    };
}
