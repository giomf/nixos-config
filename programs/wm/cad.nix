{
  ...
}:
{
  flake.modules.homeManager.cad =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # deactivate due to some build errors
        # cura

        freecad

        kicad
        temurin-jre-bin # Needed for kicads plugin freerouting
      ];
    };
}
