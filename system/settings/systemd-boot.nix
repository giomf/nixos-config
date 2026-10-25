{
  ...
}:

{
  flake.modules.nixos.systemd-boot = {
    boot = {
      kernelParams = [ "quiet" ];
      plymouth.enable = true;
      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 10;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
