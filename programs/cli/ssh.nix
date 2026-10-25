{ ... }:
{
  flake.modules.homeManager.ssh =
    { lib, pkgs, ... }:
    {
      services.ssh-agent.enable = true;
      services.gpg-agent.enable = true;
      home.activation.sshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run install -Dm600 ${pkgs.writeText "ssh-config" ''
          Host moon.guif.dev
            HostName moon.guif.dev
            Port 30049
        ''} $HOME/.ssh/config
      '';
    };
}
