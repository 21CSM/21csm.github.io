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
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.zola ];
        };

        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "21csm.github.io";
          src = self;
          nativeBuildInputs = [ pkgs.zola ];
          # Zola 0.23 builds a reqwest client while loading templates, and the
          # Nix sandbox has no system CA bundle unless this is set.
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
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
