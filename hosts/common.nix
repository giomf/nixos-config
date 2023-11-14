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
    packages = with pkgs; [
      font-awesome
      noto-fonts
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "FiraCode" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "noto-fonts" ];
        emoji = [ "noto-fonts-emoji" ];
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
  users.users.guif = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };
}

