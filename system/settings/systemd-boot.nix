{
  ...
}:

{
  flake.modules.nixos.systemd-boot = {
    boot = {
      kernelParams = [ "quiet" ];
      initrd = {
        systemd.enable = true;
      };
      plymouth.enable = true;
      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 10;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
