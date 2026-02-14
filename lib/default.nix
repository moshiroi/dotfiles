{ nixpkgs, home-manager, darwin, ... }:
{
  mkNixosSystem = { hostname, system, modules, homeModules, username, specialArgs }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specialArgs // { inherit username; };
      modules = modules ++ [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
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
            users.${username}.imports = homeModules;
            extraSpecialArgs = specialArgs // { inherit username; };
          };
        }
      ];
      pkgs = specialArgs.pkgs;
    };
}
