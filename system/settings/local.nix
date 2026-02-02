{ ... }:
{

  flake.modules.nixos.local =
    { pkgs, ... }:
    {
      time.timeZone = "Europe/Berlin";

      console = {
        keyMap = "de";
        packages = with pkgs; [ terminus_font ];
        font = "ter-u28n";
      };

      i18n = {
        defaultLocale = "de_DE.UTF-8";
        extraLocaleSettings.LC_ALL = "de_DE.UTF-8";
      };
    };
}
