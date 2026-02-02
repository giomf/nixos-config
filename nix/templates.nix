{
  ...
}:
{
  flake.modules.nixos.templates = {
    nix = {
      registry = {
        nix-templates = {
          from = {
            id = "nix-templates";
            type = "indirect";
          };
          to = {
            type = "github";
            owner = "giomf";
            repo = "nix-templates";
          };
        };
      };
    };
  };
}
