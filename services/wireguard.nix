{ ... }:

{
  flake.modules.nixos.wireguard-client =
    { lib, config, ... }:
    let
      cfg = config.mine.wireguard;
    in
    {
      options.mine.wireguard.secretFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "agenix secret holding a complete wg-quick config.";
      };

      options.mine.wireguard.autostart = lib.mkEnableOption "bringing wg0 up at boot, retrying until it connects";

      config = lib.mkIf (cfg.secretFile != null) {
        age.secrets.wireguard.file = cfg.secretFile;

        # Prevent NetworkManager from managing the WireGuard interface
        networking.networkmanager.unmanaged = [ "interface:wg0" ];

        networking.wg-quick.interfaces.wg0 = {
          inherit (cfg) autostart;
          configFile = config.age.secrets.wireguard.path;
        };

        # Endpoint may not resolve yet at boot, retry instead of staying down
        systemd.services.wg-quick-wg0.serviceConfig = lib.mkIf cfg.autostart {
          Restart = "on-failure";
          RestartSec = 10;
        };
      };
    };

  flake.modules.homeManager.wireguard =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ wireguard-tools ];
    };
}
