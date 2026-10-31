{ inputs, ... }:

{
  # TODO: drop input and overlay with the next qlcplus release (discobox, fw13)
  flake-file.inputs.qlcplus-src = {
    url = "github:mcallegari/qlcplus";
    flake = false;
  };

  flake.overlays.qlcplus = final: _: {
    # Unstable's 5.x derivation, built from master
    qlcplus =
      inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system}.qlcplus.overrideAttrs
        {
          version = "5-unstable-${inputs.qlcplus-src.shortRev}";
          src = inputs.qlcplus-src;
          # Binary reports "5.3.1 GIT", not the unstable version
          dontVersionCheck = true;
        };
  };

  flake.modules.homeManager.qlcplus =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.qlcplus ];
    };
}
