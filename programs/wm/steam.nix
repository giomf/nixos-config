{ ... }:

{

  flake.modules.nixos.steam = {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    hardware = {
      steam-hardware.enable = true;
      # bluetooth = {
      #   settings.General = {
      #     # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
      #     # for pairing bluetooth controller
      #     Privacy = "device";
      #     JustWorksRepairing = "always";
      #     Class = "0x000100";
      #     FastConnectable = true;
      #   };
      # };
      # xpadneo.enable = true;
    };
  };
}
