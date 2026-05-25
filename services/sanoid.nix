{
  ...
}:
{
  flake.modules.nixos.sanoid =
    { lib, config, ... }:
    let
      cfg = config.mine.zfs;
      datasetConfig = {
        hourly = 72;
        daily = 30;
        weekly = 4;
        monthly = 6;
        autosnap = cfg.sanoid.autosnap;
        autoprune = true;
        recursive = true;
        processChildrenOnly = true;
      };
    in
    {
      options.mine.zfs.sanoid.autosnap = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether sanoid should automatically create snapshots. Disable on syncoid receive targets.";
      };

      config = lib.mkIf (cfg.pools != [ ]) {
        services.sanoid = {
          enable = true;
          interval = "hourly";
          datasets = lib.genAttrs cfg.pools (_: datasetConfig);
        };
        users = lib.mkIf config.services.sanoid.enable {
          users.sanoid = {
            group = "sanoid";
            isSystemUser = true;
          };
          groups.sanoid = { };
        };
      };
    };
}
