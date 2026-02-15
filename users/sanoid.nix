{
  ...
}:
{
  flake.modules.nixos.sanoid = {
    users = {
      users = {
        sanoid = {
          group = "sanoid";
          isSystemUser = true;
        };
      };
      groups.sanoid = { };
    };
  };
}
