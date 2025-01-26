{
  description = "Nixos config flake";

  inputs = {
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
          specialArgs = { inherit inputs; };
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
          extraSpecialArgs = { inherit inputs; };
        };
    in
    {
      nixosConfigurations.nixos-vm = mkNixosConfig { host = hosts.nixos-vm; };
      homeConfigurations."${hosts.nixos-vm.user}@${hosts.nixos-vm.hostname}" = mkHomeConfig {
        host = hosts.nixos-vm;
      };
    };
}
