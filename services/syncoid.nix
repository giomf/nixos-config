{
  ...
}:
{
  flake.modules.nixos.syncoid =
    {
      lib,
      pkgs,
      config,
      options,
      ...
    }:
    let
      cfg = config.mine.zfs.syncoid;
    in
    {
      options.mine.zfs.syncoid.commands = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              source = lib.mkOption {
                type = lib.types.str;
                description = "Source dataset (e.g., syncoid@host:pool).";
              };
              target = lib.mkOption {
                type = lib.types.str;
                description = "Target dataset (e.g., pool).";
              };
            };
          }
        );
        default = { };
        description = "Syncoid replication commands.";
      };

      config = lib.mkIf (cfg.commands != { }) {
        environment.systemPackages = with pkgs; [
          pv
          mbuffer
          lzop
          zstd
        ];

        services.syncoid = {
          enable = true;
          # Gets created by module and lives in /var/lib/syncoid
          user = "syncoid";
          # Is created and copied manually after first run
          sshKey = "~/.ssh/id_ed25519";
          interval = "*:15";
          commands = lib.mapAttrs (_: cmd: {
            source = cmd.source;
            target = cmd.target;
            sendOptions = "w";
            recursive = true;
            extraArgs = [ "--skip-parent" ];
            localTargetAllow = options.services.syncoid.localTargetAllow.default ++ [
              "destroy"
            ];
          }) cfg.commands;
        };
      };
    };
}
