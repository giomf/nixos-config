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

        fonts
        home-manager
        local
        ssh
      ];
    };

  flake.modules.homeManager.system-default = {
    imports = with inputs.self.modules.homeManager; [
      system-minimal

      cli
      git
      helix
      shell
      ssh
    ];
  };
}
