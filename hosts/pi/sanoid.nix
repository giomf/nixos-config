{ config, pkgs, ... }:

{

  services.sanoid = {
    enable = true;
    datasets."zpool" = {
      hourly = 72;
      daily = 30;
      monthly = 12;
      yearly = 2;
      autosnap = true;
      autoprune = true;
    };
  };

  services.syncoid = {
    enable = false;
    user = "syncoid";
    commands = {
      "zpool/pihole" = {
        target = "syncoid@backup:zpool/pihole";
        recursive = true;
        sendOptions = "p";
        recvOptions = "u o readonly=on o atime=off o canmount=noauto";
        sshKey = "/home/syncoid/.ssh/id_ed25519";
        commonArgs = [
          "--sshport=30049"
          "--no-rollback"
          "--quiet"
        ];
      };
    };
  };

}
