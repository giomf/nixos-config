{ ... }:

{
  flake.modules.nixos.wireguard-client =
    { lib, config, pkgs, ... }:
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

        # shortcut: workarounds for https://github.com/NixOS/nixpkgs/issues/584414, remove both once it's fixed
        # A failed stop (e.g. conf gone from PrivateTmp) leaves wg0 behind and every start then fails with "already exists"
        systemd.services.wg-quick-wg0.preStart = "${pkgs.iproute2}/bin/ip link delete wg0 2>/dev/null || true";
        # wg-quick copies configFile into its PrivateTmp; keep tmpfiles from aging it out, or stop can't find it
        systemd.tmpfiles.rules = [ "x /tmp/systemd-private-%b-wg-quick-wg0.service-*/tmp/wg0.conf" ];

        # Endpoint may not resolve yet at boot, retry instead of staying down
        systemd.services.wg-quick-wg0.serviceConfig = lib.mkIf cfg.autostart {
          Restart = "on-failure";
          RestartSec = 10;
        };

        # Router reconnects leave a stale NAT entry that keepalives never let expire; a new source port gets a fresh one
        systemd.services.wg0-watchdog = lib.mkIf cfg.autostart {
          startAt = "*:0/2";
          requisite = [ "wg-quick-wg0.service" ];
          path = [ pkgs.wireguard-tools ];
          script = ''
            ts=$(wg show wg0 latest-handshakes | cut -f2)
            if [ $(( $(date +%s) - ''${ts:-0} )) -gt 300 ]; then
              echo "handshake stale, moving to a new source port"
              wg set wg0 listen-port 0
            fi
          '';
        };
      };
    };

  flake.modules.homeManager.wireguard =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ wireguard-tools ];
    };
}
