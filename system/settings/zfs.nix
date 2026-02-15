{ inputs, ... }:

{
  flake.modules.nixos.zfs = {
    imports = with inputs.self.modules.nixos; [ sanoid ];
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.extraPools = [ "tank" ];
    services.zfs.autoScrub.enable = true;
    services.zfs.autoScrub.interval = "monthly";
  };
}
