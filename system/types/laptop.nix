{
  inputs,
  ...
}:
{
  flake.modules.nixos.system-laptop =
    { pkgs, lib, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        system-default

        cosmic
        steam
        templates
      ];

      xdg.portal = {
        config.common.default = "*";
        enable = true;
        wlr.enable = true;
      };

      programs = {
        virt-manager.enable = true;
        wireshark = {
          enable = true;
          package = pkgs.wireshark;
        };
      };

      virtualisation = {
        docker.enable = true;
        libvirtd.enable = true;
      };

      # Security
      security = {
        # Enable sound
        rtkit.enable = true;
        sudo.wheelNeedsPassword = false;
      };

      services = {
        printing = {
          enable = true;
          drivers = [
            pkgs.brlaser
          ];
        };
        # blueman.enable = true;
        fwupd.enable = true;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
        # Not needed for fw13: https://community.frame.work/t/guide-fw13-ryzen-power-management/42988
        # auto-cpufreq.enale = true:
        upower.enable = true;

        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
      };

      networking = {
        networkmanager.enable = true;
      };

      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = lib.mkDefault false;
        };
      };
    };

  flake.modules.homeManager.system-laptop = {
    imports = with inputs.self.modules.homeManager; [
      system-default

      browsers
      cad
      cosmic
      office
      social
      terminal
    ];
  };
}
