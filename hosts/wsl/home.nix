{ pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/keyring.nix
  ];

   home.packages = with pkgs; [
     # for nix IDE
     nixpkgs-fmt
   ];

}
