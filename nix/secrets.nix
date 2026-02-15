{
  inputs,
  ...
}:
{
  flake.modules.nixos.secrets = {
    imports = [
      inputs.agenix.nixosModules.default
    ];
  };
}
