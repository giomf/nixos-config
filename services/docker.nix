{
  ...
}:
{
  flake.modules.nixos.docker = {
    virtualisation = {
      oci-containers.backend = "docker";
      docker = {
        enable = true;
        autoPrune.enable = true;
      };
    };
  };
}
