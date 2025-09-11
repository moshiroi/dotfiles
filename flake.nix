{
  description = "NixOS with Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:helix-editor/helix/master";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    niri.url = "github:sodiboo/niri-flake/main";
  };

  outputs =
    {
      nixpkgs,
      darwin,
      home-manager,
      helix,
      zen-browser,
      niri,
      ...
    }:
    let
      username = "mohamedshire";
      wsl_hostname = "nixos";
      linux_hostname = "jarvis";
      darwin_hostname = "Mohameds-MacBook-Pro";
      specialArgs = { inherit username zen-browser niri; };
    in
    {
      nixosConfigurations =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ helix.overlays.default ];
          };
        in
        {
          ${wsl_hostname} = nixpkgs.lib.nixosSystem {
            inherit pkgs system;
            modules = [
              ./wsl/configuration.nix
              ./common/linux-common.nix
              ./wsl/nvidia.nix 
              ./common/system.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true; # uses the same nixpkgs instance as your system configuration
                home-manager.useUserPackages = true;
                home-manager.users.nixos = import ./common/home.nix;
                home-manager.extraSpecialArgs = specialArgs;
              }
            ];
          };

          ${linux_hostname} = nixpkgs.lib.nixosSystem {
            inherit pkgs system specialArgs;
            modules = [
              ./linux-desktop
              ./common/linux-common.nix
              ./common/system.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true; # uses the same nixpkgs instance as your system configuration
                home-manager.useUserPackages = true;
                home-manager.users.${username} = {
                  imports = [
                    ./common/home.nix
                    ./linux-desktop/home.nix
                  ];
                  programs.niri.enable = true;
                  programs.zen-browser.enable = true;
                };
                home-manager.extraSpecialArgs = specialArgs;
              }
              # NOTE: If you want to virtualise this from a x86_64-darwin machine, uncomment the lines below
              # {
              #   virtualisation.host.pkgs = import nixpkgs {
              #     system = "x86_64-darwin";
              #   };
              # }
            ];
          };
        };

      darwinConfigurations = {
        ${darwin_hostname} =
          let
            system = "x86_64-darwin";
          in
          darwin.lib.darwinSystem {
            inherit specialArgs;
            modules = [
              ./darwin/system.nix
              ./common/system.nix
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = false;
                home-manager.users.${username} = import ./common/home.nix;
                home-manager.extraSpecialArgs = specialArgs;
              }
            ];
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [ helix.overlays.default ];
            };
          };
      };

      homeManagerModules = {
        home = ./common/home.nix;
      };
    };
}
