{
  ...
}:
{
  flake.modules.homeManager.cad =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        cura-appimage
        freecad
        kicad
        temurin-jre-bin # Needed for kicads plugin freerouting
      ];
    };
}
