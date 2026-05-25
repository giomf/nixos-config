{
  ...
}:
{
  flake.modules.nixos.smartd =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.smartmontools ];
      services.smartd = {
        enable = true;
        autodetect = true;
        notifications.wall.enable = true; # broadcasts to all logged-in users
      };
    };
}
