{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      hosts = import ./config/hosts.nix;
      mkNixosConfig =
        { host }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit host;
          };
          modules = [
            ./hosts/${host.dir}/configuration.nix
            ./system
          ];
        };
      mkHomeConfig =
        { host }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = host.arch;
            config = {
              allowUnfree = true;
            };
          };
          modules = [
            ./hosts/${host.dir}/home.nix
            ./home
          ];
          extraSpecialArgs = {
            inherit inputs;
            inherit host;
            rootPath = ./.;
          };
        };
    in
    {
      nixosConfigurations.nixos-vm = mkNixosConfig { host = hosts.nixos-vm; };
      homeConfigurations."${hosts.nixos-vm.user}@${hosts.nixos-vm.hostname}" = mkHomeConfig {
        host = hosts.nixos-vm;
      };

      nixosConfigurations.jasper-gos = mkNixosConfig { host = hosts.jasper-gos; };
      homeConfigurations."jasper@jasper-gos" = mkHomeConfig {
        host = hosts.jasper-gos;
      };

      nixosConfigurations.jasper-desk = mkNixosConfig { host = hosts.jasper-desk; };
      homeConfigurations."jasper@jasper-desk" = mkHomeConfig {
        host = hosts.jasper-desk;
      };
    };
}
