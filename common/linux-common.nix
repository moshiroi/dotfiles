{ config, pkgs, ... }: {
  # NOTE: Tailscale broken on 25.05
  # services.tailscale.enable = true;
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     # Listen on all interfaces
  #     ListenAddress = "0.0.0.0";
  #     # Or specifically on Tailscale
  #     # ListenAddress = "100.x.y.z"; # Your Tailscale IP
  #   };
  # };

  # Enable NVIDIA drivers and CUDA support
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = false;
    };

    # Add NVIDIA packages
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
    };

    # opengl has been renamed to graphics
    opengl = {
      enable = true;
      # driSupport = true;
      driSupport32Bit = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  environment = {
    sessionVariables = {
      CUDA_PATH = "${pkgs.cudatoolkit}";
      EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
      EXTRA_CCFLAGS = "-I/usr/include";
      LD_LIBRARY_PATH = [
        "/usr/lib/wsl/lib"
        "${pkgs.linuxPackages.nvidia_x11}/lib"
        "${pkgs.ncurses5}/lib"
      ];
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "Nvidia";
    };

    # Install CUDA toolkit and related packages
    systemPackages = with pkgs; [
      cudatoolkit
      linuxPackages.nvidia_x11
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
    ];
  };
}
