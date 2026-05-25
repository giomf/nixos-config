{ inputs, ... }:

{
  flake.modules.nixos.zfs =
    { lib, config, ... }:
    let
      cfg = config.mine.zfs;
    in
    {
      imports = with inputs.self.modules.nixos; [ sanoid smartd ];

      options.mine.zfs.pools = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "ZFS pools to import and manage.";
      };

      config = lib.mkIf (cfg.pools != [ ]) {
        boot.supportedFilesystems = [ "zfs" ];
        boot.zfs.extraPools = cfg.pools;
        services.zfs.autoScrub.enable = true;
        services.zfs.autoScrub.interval = "monthly";
      };
    };
}
