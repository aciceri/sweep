{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        { config
        , inputs'
        , pkgs
        , lib
        , zmk-nix
        , ...
        }: {
          _module.args.zmk-nix = inputs'.zmk-nix;

          packages = {
            firmware = zmk-nix.legacyPackages.buildSplitKeyboard {
              name = "sweep-firmware";

              src = lib.sourceFilesBySuffices inputs.self [ ".conf" ".keymap" ".yml" ];

              board = "nice_nano_v2";
              shield = "cradio_%PART%";

              zephyrDepsHash = "sha256-pOMHPrw2mlQ8H8kjG/CCTtB/drwc54gk74eA70YwEk4=";

              meta = {
                description = "ZMK firmware for the sweep keyboard";
                license = lib.licenses.gpl3;
                platforms = lib.platforms.all;
              };
            };

            default = config.packages.firmware;

            flash = zmk-nix.packages.flash.override { inherit (config.packages) firmware; };

            update = zmk-nix.packages.update;
          };

          devShells.default = zmk-nix.devShells.default;

          formatter = pkgs.nixpkgs-fmt;
        };
    };
}
