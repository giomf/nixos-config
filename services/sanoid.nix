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
          hourly = 72;
          daily = 30;
          weekly = 4;
          monthly = 6;
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
