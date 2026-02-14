{ config, pkgs, ... }:
{
  # Enable NVIDIA drivers and CUDA support
  services.xserver.videoDrivers = [ "nvidia" ];
  programs.nix-ld.enable = true;

  hardware = {
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = false;
    };

    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
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
