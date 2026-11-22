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
          # One family everywhere: Fira Code for monospace, Fira Sans for text
          fira-sans
          nerd-fonts.fira-code
          # Fallback only, for scripts and symbols Fira lacks
          noto-fonts
          noto-fonts-color-emoji

          roboto # Used for tpyst cv
          source-sans-pro # Used for typst cv
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            emoji = [ "Noto Color Emoji" ];
            monospace = [ "FiraCode Nerd Font Mono" ];
            sansSerif = [ "Fira Sans" ];
            # Fira has no serif font
            serif = [ "Fira Sans" ];
          };
        };
      };
    };
}
