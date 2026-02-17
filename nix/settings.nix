{
  ...
}:
{
  flake.modules.nixos.nix-settings =
    { pkgs, config, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [ "@wheel" ];
        };
      };

      system.activationScripts.preActivation = ''
        if [[ -e /run/current-system ]]; then
          echo "--- diff to current-system"
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
          echo "---"
        fi
      '';
    };

}
