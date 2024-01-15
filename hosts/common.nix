{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Europe/Berlin";
  console = {
    keyMap = "de";
    packages = with pkgs; [ terminus_font ];
    font = "ter-u28n";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      font-awesome
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "FiraCode" ]; })
      noto-fonts
      noto-fonts-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  i18n = {
    defaultLocale = "de_DE.UTF-8";
    extraLocaleSettings.LC_ALL = "de_DE.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;
  programs.fish.enable = true;

  security = {
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  # User
  users.users = {
    #disable root password
    root.hashedPassword = "!";
    guif = {
      isNormalUser = true;
      shell = pkgs.fish;
      initialHashedPassword = "$y$j9T$hHZ1NIxqNvPno5mkSDSjI1$PojSMDbnHYHcrrdaTw74w6tSlLIRvMCbCbaCiDpMx3.";
      extraGroups = [
        "wheel"
        "docker"
      ];
    };
  };
}

