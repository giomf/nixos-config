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
        # kicad with extra Python packages available to plugins (scipy, shapely).
        # overrideAttrs extends the pythonPath list used by wrapPython, which
        # builds the PYTHONPATH that kicad sets on all its wrapped binaries.
        (kicad.overrideAttrs (old: {
          pythonPath =
            old.pythonPath
            ++ (with python3Packages; [
              # Used for KiCad Routing tools
              scipy
              shapely
            ]);
        }))
        easyeda2kicad
        temurin-jre-bin # Needed for kicads plugin freerouting
      ];
    };
}
