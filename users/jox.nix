{
  inputs,
  ...
}:
{

  flake.homeConfigurations = {
    jox = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    };
  };

  flake.modules.nixos.jox =
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
          jox = {
            group = "jox";
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPFFcwAmUu6RWmlNlu8ARQYKZzaVs8Xnj4Nx3aXKsnN"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw guif@glap"
            ];
            isNormalUser = true;
            extraGroups = [
              "docker"
              "ssh"
            ];
            shell = pkgs.fish;
          };
        };
        groups = {
          jox = { };
        };
      };
    };
}
