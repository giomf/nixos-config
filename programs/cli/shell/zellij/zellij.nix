{ ... }:

{
  flake.modules.homeManager.shell = {
    programs.zellij = {
      enable = true;
    };
    xdg = {
      enable = true;
      configFile."zellij/config.kdl".source = ./config.kdl;
      configFile."zellij/layouts/default.kdl".source = ./layout.kdl;
    };
  };
}
