{
  ...
}:
{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
          font-awesome
          nerd-fonts.fira-code
          nerd-fonts.symbols-only
          noto-fonts
          noto-fonts-color-emoji

          roboto # Used for tpyst cv
          source-sans-pro # Used for typst cv
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
    };
}
