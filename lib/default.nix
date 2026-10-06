{ nixpkgs, home-manager, darwin, overlays, ... }:
{
  mkNixosSystem = { hostname, system, modules, homeModules, username, specialArgs }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specialArgs // { inherit username; };
      modules = modules ++ [
        # Let NixOS build pkgs itself (passing a prebuilt one via specialArgs
        # makes it ignore nixpkgs.* options and warn).
        {
          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;
        }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            users.${username}.imports = homeModules;
            extraSpecialArgs = specialArgs // { inherit username; };
          };
        }
      ];
    };

  mkDarwinSystem = { hostname, system, modules, homeModules, username, specialArgs }:
    darwin.lib.darwinSystem {
      specialArgs = specialArgs // { inherit username; };
      modules = modules ++ [
        { nixpkgs.hostPlatform = system; }
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = false;
            backupFileExtension = "bak";
            users.${username}.imports = homeModules;
            extraSpecialArgs = specialArgs // { inherit username; };
          };
        }
      ];
      pkgs = specialArgs.pkgs;
    };
}
