{
  description = "OpenVPN3 CLI Tool - A simple interactive CLI wrapper for OpenVPN3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        openvpn-nesto-cli = pkgs.stdenv.mkDerivation rec {
          pname = "openvpn-nesto-cli";
          version = "1.0.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];

          buildInputs = with pkgs; [
            bash
            openvpn3
            gawk
            gnugrep
            coreutils
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            cp openvpn-nesto $out/bin/openvpn-nesto-cli
            chmod +x $out/bin/openvpn-nesto-cli

            wrapProgram $out/bin/openvpn-nesto-cli \
              --prefix PATH : ${
                pkgs.lib.makeBinPath [
                  pkgs.openvpn3
                  pkgs.gawk
                  pkgs.gnugrep
                  pkgs.coreutils
                ]
              }

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "OpenVPN3 CLI Tool - A simple interactive CLI wrapper for OpenVPN3";
            longDescription = ''
              A bash script that provides an interactive command-line interface for OpenVPN3.
              Features include connect, disconnect, status checking, and configuration management.
            '';
            homepage = "https://github.com/nesto-software/openvpn-nesto-cli";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.linux;
            mainProgram = "openvpn-nesto-cli";
          };
        };
      in
      {
        packages.default = openvpn-nesto-cli;
        packages.openvpn-nesto-cli = openvpn-nesto-cli;

        apps.default = flake-utils.lib.mkApp {
          drv = openvpn-nesto-cli;
          name = "openvpn-nesto-cli";
        };

        overlays.default = final: prev: {
          openvpn-nesto-cli = openvpn-nesto-cli;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            openvpn3
            gawk
            gnugrep
            coreutils
          ];

          shellHook = ''
            echo "OpenVPN Nesto CLI development environment"
            echo "Run './openvpn-nesto-cli' to test the script"
          '';
        };
      }
    );
}
