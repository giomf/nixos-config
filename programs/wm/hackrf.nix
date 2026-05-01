{
  ...
}:
{
  flake.modules.nixos.hackrf = {
    hardware.hackrf.enable = true;
  };
  flake.modules.homeManager.hackrf =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        hackrf
        gqrx
        gnuradio
        sdrpp
      ];
    };
}
