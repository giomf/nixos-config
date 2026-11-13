{
  flake.modules.homeManager.qlcplus =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.qlcplus ];
    };
}
