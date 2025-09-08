{
  config,
  pkgs,
  ...
}:
{
  # Required for getting nvidia container device interface working
  # Working with GPU from within docker container. Currently service does not start
  # See blogpost: https://yomaq.github.io/posts/nvidia-on-nixos-wsl-ollama-up-24-7-on-your-gaming-pc/
  systemd.services = {
    nvidia-cdi-generator = {
      description = "Generate nvidia cdi";
      wantedBy = [ "docker.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.nvidia-docker}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml --nvidia-ctk-path=${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk";
      };
    };
  };

  virtualisation.docker = {
    daemon.settings.features.cdi = true;
    daemon.settings.cdi-spec-dirs = [ "/etc/cdi" ];
  };

}
