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
      # Same CLI tools and fish setup after `sudo -i` / `su`
      users.users.root.shell = pkgs.fish;
      home-manager.users.root = {
        imports = with inputs.self.modules.homeManager; [
          cli
          shell
        ];
        home.stateVersion = "23.05";
      };
    };

  flake.modules.homeManager.system-server = {
    imports = with inputs.self.modules.homeManager; [
      system-default
    ];
  };
}
