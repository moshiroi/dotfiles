{
  description = "NixOS + nix-darwin + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:helix-editor/helix/master";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      darwin,
      home-manager,
      helix,
      zen-browser,
      nixos-wsl,
      ...
    }:
    let
      lib = import ./lib { inherit nixpkgs home-manager darwin; };
      overlays = import ./overlays { inherit helix; };

      mkPkgs = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      specialArgs = { inherit zen-browser; };
    in
    {
      nixosConfigurations = {
        # WSL2 NixOS config
        nixos = lib.mkNixosSystem {
          hostname = "nixos";
          system = "x86_64-linux";
          username = "nixos";
          specialArgs = specialArgs // { inherit nixos-wsl; pkgs = mkPkgs "x86_64-linux"; };
          modules = [
            ./hosts/wsl
            ./modules/common/system.nix
          ];
          homeModules = [ ./modules/home ];
        };

        # x86_64 NixOS config (home pc)
        jarvis = lib.mkNixosSystem {
          hostname = "jarvis";
          system = "x86_64-linux";
          username = "mohamedshire";
          specialArgs = specialArgs // { pkgs = mkPkgs "x86_64-linux"; };
          modules = [
            ./hosts/jarvis
            ./modules/common/system.nix
          ];
          homeModules = [
            ./modules/home
            ./modules/home/desktop.nix
          ];
        };
      };

      darwinConfigurations = {
        # M4 MacBook Pro (aarch64)
        "Mohameds-MacBook-Pro" = lib.mkDarwinSystem {
          hostname = "Mohameds-MacBook-Pro";
          system = "aarch64-darwin";
          username = "mohamedshire";
          specialArgs = specialArgs // { pkgs = mkPkgs "aarch64-darwin"; };
          modules = [
            ./hosts/darwin
            ./modules/common/system.nix
          ];
          homeModules = [ ./modules/home ];
        };

        # Intel Mac Pro (x86_64)
        "Mohameds-Mac-Pro" = lib.mkDarwinSystem {
          hostname = "Mohameds-Mac-Pro";
          system = "x86_64-darwin";
          username = "mohamedshire";
          specialArgs = specialArgs // { pkgs = mkPkgs "x86_64-darwin"; };
          modules = [
            ./hosts/darwin
            ./modules/common/system.nix
          ];
          homeModules = [ ./modules/home ];
        };
      };

      homeManagerModules = {
        home = import ./modules/home;
      };
    };
}
