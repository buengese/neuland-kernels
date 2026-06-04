{
  description = "Neuland Linux kernel packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        let
          neulandLinuxPackages = pkgs.callPackage ./neuland-kernel.nix { };
          zfsModule = neulandLinuxPackages.${pkgs.zfs.kernelModuleAttribute};
        in
        {
          packages = {
            neuland-kernel = neulandLinuxPackages.kernel;
            neuland-zfs = zfsModule;
            zfs = pkgs.zfs;
            default = neulandLinuxPackages.kernel;
          };

          legacyPackages.neulandLinuxPackages = neulandLinuxPackages;
        };
    };
}
