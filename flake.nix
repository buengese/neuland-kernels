{
  description = "Neuland Linux kernel packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          neulandLinuxPackages = pkgs.callPackage ./neuland-kernel.nix { };
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          packages = {
            neuland-kernel = neulandLinuxPackages.kernel;
            neuland-zfs = neulandLinuxPackages.${pkgs.zfs.kernelModuleAttribute};

            default = neulandLinuxPackages.kernel;
          };

          legacyPackages = {
            inherit neulandLinuxPackages;
          };
        };
    };
}
