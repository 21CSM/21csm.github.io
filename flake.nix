{
  description = "Zola site built with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Newest Zola that still builds Serene 4.3.0.
        # 0.22 replaced the highlighting config this theme uses, and 0.23
        # removed shortcodes. Serene 6 follows those releases and redesigns
        # the theme, so pkgs.zola from nixpkgs unstable is intentionally unused.
        zolaVersion = "0.21.0";
        zolaTargets = {
          "x86_64-linux" = {
            target = "x86_64-unknown-linux-gnu";
            hash = "sha256-XDeo9wZWfWytPw28Dq6+O5WRzDAb1nCJ5d3A0EAXMtY=";
          };
          "aarch64-linux" = {
            target = "aarch64-unknown-linux-gnu";
            hash = "sha256-2n6d73uazwybePuZznJiRQTP7hBmq3oWHwmkEm3X/+Y=";
          };
          "x86_64-darwin" = {
            target = "x86_64-apple-darwin";
            hash = "sha256-G7iW1Sh37mN7Fva41YJ+weWrvUp4tUGnccZc67EPR+g=";
          };
          "aarch64-darwin" = {
            target = "aarch64-apple-darwin";
            hash = "sha256-X6jTPILumZDLQQIL/wzkDK+Y/k5G04/fJ0CoGmx479o=";
          };
        };
        zolaTarget = zolaTargets.${system} or (throw "no Zola 0.21.0 binary for ${system}");

        zola = pkgs.stdenvNoCC.mkDerivation {
          pname = "zola";
          version = zolaVersion;
          src = pkgs.fetchurl {
            url = "https://github.com/getzola/zola/releases/download/v${zolaVersion}/zola-v${zolaVersion}-${zolaTarget.target}.tar.gz";
            hash = zolaTarget.hash;
          };
          dontUnpack = true;
          dontBuild = true;
          # The Linux release is dynamically linked. Darwin builds ship a Mach-O
          # binary and do not need patchelf.
          nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
          buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.glibc pkgs.stdenv.cc.cc.lib ];
          dontStrip = pkgs.stdenv.hostPlatform.isDarwin;
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            tar -xzf $src -C $out/bin
            chmod +x $out/bin/zola
            runHook postInstall
          '';
          meta = {
            mainProgram = "zola";
            description = "Fast static site generator with everything built-in";
            homepage = "https://www.getzola.org/";
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ zola ];
        };

        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "21csm.github.io";
          src = self;
          nativeBuildInputs = [ zola ];
          buildPhase = ''
            runHook preBuild
            zola build
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            cp -r public $out
            runHook postInstall
          '';
        };
      }
    );
}
