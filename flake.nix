{
  description = "NixOS config flake";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://rstrf.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-substituters = [
      "https://hyprland.cachix.org"
      "https://rstrf.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "rstrf.cachix.org-1:uxjunq8cQ7mGYWxsPnqK2/lWLm7lP+A8EvQP39yYjFY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    # Uncomment to use ashell flake
    # ashell = {
    #   url = "github:MalpenZibo/ashell";
    #   # Whenever nixpkgs changes, we have to rebuild all of the Cargo deps
    #   inputs.nixpkgs.follows = "nixpkgs-stable";
    # };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DON'T follow nixpkgs here, so that we can use the Cachix builds
    # FIXME: remove fixed refs for hyprland and hy3 once this is merged:
    # https://github.com/outfoxxed/hy3/pull/261
    hyprland.url = "github:hyprwm/hyprland";
    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };
    waveforms = {
      url = "github:liff/waveforms-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rstrf.url = "github:jazzpi/rstrf";
    llm-agents.url = "github:numtide/llm-agents.nix";
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
            llm = "llm";
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
      packages.x86_64-linux =
        let
          pkgs = mkPkgs { arch = "x86_64-linux"; };
        in
        {
          oscarwatch = pkgs.callPackage ./packages/oscarwatch { };
          openocd-git = pkgs.callPackage ./packages/openocd-git { };
          stm32cubeprog = pkgs.callPackage ./packages/stm32cubeprog { };
          gr-satellites = pkgs.callPackage ./packages/gr-satellites { };
          thermal-camera-redux = pkgs.callPackage ./packages/thermal-camera-redux { };
          yamcs-studio = pkgs.callPackage ./packages/yamcs-studio { };
          strf = pkgs.callPackage ./packages/strf { };
          stvid = pkgs.callPackage ./packages/stvid { };
          astroimagej = pkgs.callPackage ./packages/astroimagej { };
        };
    };
}
