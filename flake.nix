{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;

      users_ = {
        jasper = {
          groups = [
            "wheel"
            "dialout"
            "plugdev"
            "networkmanager"
          ];
        };
      };
      getUser =
        name:
        (nixpkgs.lib.getAttrFromPath [ name ] users_)
        // {
          inherit name;
        };
      defaultUser = "jasper";

      hosts =
        let
          defaultHost = {
            arch = "x86_64-linux";
            user = getUser defaultUser;
          };
        in
        {
          nixos-vm = defaultHost;
          jasper-gos = defaultHost;
          jasper-desk = defaultHost;
          jasper-fw = defaultHost;
        };

      mkPkgsStable =
        host:
        import nixpkgs-stable {
          system = host.arch;
          config = {
            allowUnfree = true;
          };
        };
      optionalExists = path: lib.optional (builtins.pathExists path) path;
      mkNixosConfig =
        host:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs host;
            pkgs-stable = mkPkgsStable host;
          };
          modules = [
            ./common
            ./sys
            ./hosts/${host.name}/sys.nix
          ] ++ optionalExists ./hosts/${host.name}/common.nix;
        };
      mkHomeConfig =
        host:
        let
          pkgs_ = import nixpkgs {
            system = host.arch;
            config = {
              allowUnfree = true;
            };
          };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs_;
          modules = [
            ./common
            ./home
            ./hosts/${host.name}/home.nix
          ] ++ optionalExists ./hosts/${host.name}/common.nix;
          extraSpecialArgs = {
            inherit
              inputs
              host
              rootPath
              repoPath
              ;
            pkgs-stable = mkPkgsStable host;
            templateFile = import "${rootPath}/util/template-file.nix" { pkgs = pkgs_; };
          };
        };

      rootPath = ./.;
      repoPath = "~/nixcfg";
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostname: host: mkNixosConfig (host // { name = hostname; })
      ) hosts;
      homeConfigurations = lib.mapAttrs' (hostname: host: {
        name = "${host.user.name}@${hostname}";
        value = mkHomeConfig (host // { name = hostname; });
      }) hosts;
    };
}
