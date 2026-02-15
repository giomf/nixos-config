{
  ...
}:
{
  flake.modules.nixos.apc-usp =
    { pkgs, ... }:
    {
      services.apcupsd.enable = true;

    };
}
