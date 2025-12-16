{
  description = "NixOS config flake";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://hyprland.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    ashell = {
      url = "github:jazzpi/ashell/jasper-dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DON'T follow nixpkgs here, so that we can use the Cachix builds
    # FIXME: remove fixed refs for hyprland and hy3 once this is merged:
    # https://github.com/outfoxxed/hy3/pull/261
    hyprland.url = "github:hyprwm/hyprland/?ref=bb963fb00263bac78a0c633d1d0d02ae4763222c";
    hy3 = {
      url = "github:outfoxxed/hy3/?ref=c0437b27a30569aeafcab7d6f02a0fc14b6ebd77";
      inputs.hyprland.follows = "hyprland";
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
        (lib.getAttrFromPath [ name ] users_)
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

      mkPkgs =
        host:
        import nixpkgs {
          system = host.arch;
          config = {
            allowUnfree = true;
          };
        };
      mkPkgsStable =
        host:
        import nixpkgs-stable {
          system = host.arch;
          config = {
            allowUnfree = true;
          };
        };
      mkTemplateFile = pkgs: import "${rootPath}/util/template-file.nix" { inherit pkgs; };

      # TODO: dynamically determine wallpaper from date
      # I used to do this at rebuild time, but it made the rebuilds quite slow
      # because the derivation for getting the date had to be evaluated each
      # time. So it should probably be done at runtime instead.
      wallpaperPath = "${rootPath}/assets/wallpapers/2025/0.jpg";
      optionalExists = path: lib.optional (builtins.pathExists path) path;
      mkNixosConfig =
        host:
        lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              host
              rootPath
              wallpaperPath
              ;
            pkgs-stable = mkPkgsStable host;
            templateFile = mkTemplateFile host;
          };
          modules = [
            ./modules/common
            ./modules/sys
            ./private/sys
            ./hosts/${host.name}/sys.nix
          ]
          ++ optionalExists ./hosts/${host.name}/common.nix;
        };
      mkHomeConfig =
        host:
        let
          pkgs_ = mkPkgs host;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs_;
          modules = [
            ./modules/common
            ./modules/home
            ./private/home
            ./hosts/${host.name}/home.nix
          ]
          ++ optionalExists ./hosts/${host.name}/common.nix;
          extraSpecialArgs = {
            inherit
              inputs
              host
              rootPath
              repoPath
              wallpaperPath
              ;
            pkgs-stable = mkPkgsStable host;
            templateFile = mkTemplateFile pkgs_;
          };
        };

      rootPath = ./.;
      repoPath = "~/nixcfg";
    in
    {
      nixosConfigurations = lib.mapAttrs (
        hostname: host: mkNixosConfig (host // { name = hostname; })
      ) hosts;
      homeConfigurations = lib.mapAttrs' (hostname: host: {
        name = "${host.user.name}@${hostname}";
        value = mkHomeConfig (host // { name = hostname; });
      }) hosts;
    };
}
