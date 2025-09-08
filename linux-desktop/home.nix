{ zen-browser, niri, ... }: {
  imports = [ zen-browser.homeModules.beta niri.homeModules.niri ];

  programs.niri.enable = true;
  programs.zen-browser.enable = true;

}
