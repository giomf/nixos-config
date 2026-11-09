{ inputs, ... }:

{
  # TODO: drop input and use pkgs.mitos once NixOS/nixpkgs#576743 lands
  flake-file.inputs.mitos-pr = {
    url = "github:giomf/nixpkgs/mitos-0.1.1";
    flake = false;
  };

  flake.modules.homeManager.mitos =
    { pkgs, config, ... }:
    {
      home.packages =
        let
          mitosPkgs = import inputs.mitos-pr { inherit (pkgs.stdenv.hostPlatform) system; };
        in
        [
          # PR packaging, bumped to 0.1.3
          (mitosPkgs.mitos.override {
            mitos-unwrapped = mitosPkgs.mitos-unwrapped.overrideAttrs (old: rec {
              version = "0.2.0";
              src = old.src.override {
                tag = "v${version}";
                hash = "sha256-vOWgeidfRGg4pP/n28wzgJQJKnZa2zNpb+c/PSRWDRw=";
              };
              cargoHash = "sha256-28bhJr1hJALO+grbpd1zE7lauKlElB3gSsREgFdaurE=";
              # TODO: re-enable; render::tests syntax-timing tests fail in the sandbox since 0.2.0
              doCheck = false;
            });
          })
        ];

      # Helix fork: own config.toml (format diverges), languages.toml still shared with helix
      xdg.configFile = {
        "mitos/config.toml".source = ./config.toml;
        "mitos/languages.toml".source = config.xdg.configFile."helix/languages.toml".source;
        # mitos ignores the .aff SET line and only reads UTF-8; de_DE ships ISO8859-1
        "mitos/runtime/dictionaries/de_DE".source =
          pkgs.runCommand "hunspell-de_DE-utf8" { nativeBuildInputs = [ pkgs.iconv ]; }
            ''
              mkdir $out
              d=${pkgs.hunspellDicts.de_DE}/share/hunspell
              iconv -f ISO-8859-1 -t UTF-8 $d/de_DE.dic > $out/de_DE.dic
              iconv -f ISO-8859-1 -t UTF-8 $d/de_DE.aff | sed 's/^SET ISO8859-1/SET UTF-8/' > $out/de_DE.aff
            '';
      };
    };
}
