{
  description = "NixOS config flake";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://hyprland.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
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
    # FIXME: remove & use nixpkgs version once this is packaged:
    # https://github.com/hyprwm/hypridle/commit/f158b2fe9293f9b25f681b8e46d84674e7bc7f01
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
      inputs.systems.follows = "hyprland/systems";
      inputs.hyprlang.follows = "hyprland/hyprlang";
      inputs.hyprutils.follows = "hyprland/hyprutils";
      inputs.hyprland-protocols.follows = "hyprland/hyprland-protocols";
      inputs.hyprwayland-scanner.follows = "hyprland/hyprwayland-scanner";
    };
    waveforms = {
      url = "github:liff/waveforms-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    # FIXME: upstream this
    wpaperd.url = "github:jazzpi/wpaperd/jasper-dev";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      niri,
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

      paths =
        let
          defs = rec {
            shells = "shells";
            dots = "dotfiles";
            dots-repo = "dotfiles-repo";
            bin = "bin";
            pkgs = "packages";
            assets = "assets";
            wallpapers = "${assets}/wallpapers";
            lib = "util";
          };
        in
        {
          store = lib.mapAttrs (name: path: "${./.}/${path}") defs;
          repo = lib.mapAttrs (name: path: "~/nixcfg/${path}") defs;
        };

      mkPkgs =
        host:
        import nixpkgs {
          system = host.arch;
          config = {
            allowUnfree = true;
          };
          overlays = [ niri.overlays.niri ];
        };
      mkPkgsStable =
        host:
        import nixpkgs-stable {
          system = host.arch;
          config = {
            allowUnfree = true;
          };
        };
      mkTemplateFile = pkgs: import "${paths.store.lib}/template-file.nix" { inherit pkgs; };

      optionalExists = path: lib.optional (builtins.pathExists path) path;
      mkNixosConfig =
        host:
        lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              host
              paths
              ;
            pkgs-stable = mkPkgsStable host;
            templateFile = mkTemplateFile host;
          };
          modules = [
            ./modules/common
            ./modules/sys
            ./private/sys
            ./hosts/${host.name}/sys.nix
            niri.nixosModules.niri
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
            niri.homeModules.niri
          ]
          ++ optionalExists ./hosts/${host.name}/common.nix;
          extraSpecialArgs = {
            inherit
              inputs
              host
              paths
              ;
            pkgs-stable = mkPkgsStable host;
            templateFile = mkTemplateFile pkgs_;
          };
        };
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
