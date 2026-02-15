{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-minimal =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [ nix-settings ];
    };

  flake.modules.homeManager.system-minimal =
    { config, ... }:
    {
      home.stateVersion = "23.05";
      home.homeDirectory = "/home/${config.home.username}";
      programs = {
        home-manager.enable = true;
      };
    };
}
