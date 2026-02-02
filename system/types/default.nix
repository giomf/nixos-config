{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-default =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        system-minimal
        home-manager
        fonts
        local
      ];
    };

  flake.modules.homeManager.system-default = {
    imports = with inputs.self.modules.homeManager; [
      system-minimal
      git
      helix
      shell
      ssh
      cli
    ];
  };
}
