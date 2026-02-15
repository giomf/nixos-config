{
  ...
}:
{
  flake.modules.nixos.fail2ban = {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
      bantime = "10m";
      bantime-increment = {
        enable = true;
        overalljails = true;
      };
    };
  };
}
