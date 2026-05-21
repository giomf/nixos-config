{
  ...
}:
{
  flake.modules.nixos.sdr = {
    hardware.hackrf.enable = true;
    hardware.rtl-sdr.enable = true;
  };
  flake.modules.homeManager.sdr =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        hackrf
        gqrx
        gnuradio
        sdrpp
        rtl-sdr
      ];
    };
}
