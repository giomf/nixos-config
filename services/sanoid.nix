{
  ...
}:
{
  flake.modules.nixos.sanoid =
    { lib, config, ... }:
    {
      services.sanoid = {
        enable = true;
        interval = "hourly";
        datasets.tank = {
          hourly = 1;
          daily = 30;
          monthly = 12;
          yearly = 3;
          autosnap = true;
          autoprune = true;
          recursive = true;
          processChildrenOnly = true;
        };
      };
      users = lib.mkIf config.services.sanoid.enable {
        users = {
          sanoid = {
            group = "sanoid";
            isSystemUser = true;
          };
        };
        groups.sanoid = { };
      };
    };
}
