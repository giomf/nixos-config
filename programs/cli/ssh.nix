{ ... }:
{
  flake.modules.homeManager.ssh = {
    services.ssh-agent.enable = true;
    services.gpg-agent.enable = true;
    programs.ssh = {
      enable = false;
      extraConfig = ''
        Host backup.guif.dev
          HostName backup.guif.dev
          Port 30049
      '';
    };
  };
}
