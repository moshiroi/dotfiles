{ ... }:
{
  # NOTE: Tailscale broken on 25.05
  # TODO: Setup some firewall rules
  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      # Listen on all interfaces
      ListenAddress = "0.0.0.0";
      # Or specifically on Tailscale
      # ListenAddress = "100.x.y.z"; # Your Tailscale IP
    };
  };
}
