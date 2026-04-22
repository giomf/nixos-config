{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-server =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        system-default

        fail2ban
      ];
      security = {
        sudo.wheelNeedsPassword = false;
      };
      services = {
        fwupd.enable = true;
      };
    };

  flake.modules.homeManager.system-server = {
    imports = with inputs.self.modules.homeManager; [
      system-default
    ];
  };
}
