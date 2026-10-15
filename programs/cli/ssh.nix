{ ... }:
{
  flake.modules.homeManager.ssh = {
    services.ssh-agent.enable = true;
    services.gpg-agent.enable = true;
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host moon.guif.dev
          HostName moon.guif.dev
          Port 30049
      '';
    };
  };
}
