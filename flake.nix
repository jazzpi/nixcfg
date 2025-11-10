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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/hyprland";
    hy3 = {
      url = "github:outfoxxed/hy3";
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
      mkTemplateFile = host: import "${rootPath}/util/template-file.nix" { pkgs = mkPkgs host; };

      mkWallpaperPath =
        {
          host,
          month ? -1,
        }:
        let
          templateFile = mkTemplateFile host;
          getWallpaperPath = (
            templateFile {
              name = "get-wallpaper-path";
              template = "${rootPath}/dotfiles/hypr/scripts/get-wallpaper-path.mustache.sh";
              data = {
                wallpapersDir = "${rootPath}/assets/wallpapers";
              };
            }
          );
        in
        lib.removeSuffix "\n" (
          lib.readFile (
            (mkPkgs host).runCommand "wallpaper-path" { }
              "${getWallpaperPath} ${if month == -1 then "" else toString month} > $out"
          )
        );
      optionalExists = path: lib.optional (builtins.pathExists path) path;
      mkNixosConfig =
        host:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              host
              rootPath
              ;
            pkgs-stable = mkPkgsStable host;
            templateFile = mkTemplateFile host;
            mkWallpaperPath = args: mkWallpaperPath (args // { host = host; });
          };
          modules = [
            ./common
            ./sys
            ./hosts/${host.name}/sys.nix
          ]
          ++ optionalExists ./hosts/${host.name}/common.nix;
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
          ]
          ++ optionalExists ./hosts/${host.name}/common.nix;
          extraSpecialArgs = {
            inherit
              inputs
              host
              rootPath
              repoPath
              ;
            pkgs-stable = mkPkgsStable host;
            templateFile = mkTemplateFile host;
            mkWallpaperPath = args: mkWallpaperPath (args // { host = host; });
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
