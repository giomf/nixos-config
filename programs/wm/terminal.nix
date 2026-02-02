{
  ...
}:
{
  flake.modules.homeManager.terminal =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        alacritty
      ];

      programs.kitty = {
        enable = true;
        settings = {
          enable_audio_bell = false;
          confirm_os_window_close = 0;
        };
      };
    };
}
