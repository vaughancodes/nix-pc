
{ config, pkgs, lib, ... }:

let
  sddm-reactionary = import ../derivations/sddm-reactionary.nix { inherit pkgs; };
in
{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];


  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    theme = "reactionary";
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtvirtualkeyboard
    ];
    settings.Theme = {
      CursorTheme = "retrosmart-xcursor-white-color";
      CursorSize = 36;
    };
  };
  services.desktopManager.plasma6.enable = true;
  environment.systemPackages = [ sddm-reactionary ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Swing on suspend
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false"; 

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    # powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    # attempt a downgrade for borderlands 4
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #   version = "575.64.05";
    #   sha256_64bit = "sha256-hfK1D5EiYcGRegss9+H5dDr/0Aj9wPIJ9NVWP3dNUC0=";
    #   sha256_aarch64 = "sha256-GRE9VEEosbY7TL4HPFoyo0Ac5jgBHsZg9sBKJ4BLhsA=";
    #   openSha256 = "sha256-mcbMVEyRxNyRrohgwWNylu45vIqF+flKHnmt47R//KU=";
    #   settingsSha256 = "sha256-o2zUnYFUQjHOcCrB0w/4L6xI1hVUXLAWgG2Y26BowBE=";
    #   persistencedSha256 = "sha256-2g5z7Pu8u2EiAh5givP5Q1Y4zk4Cbb06W37rf768NFU=";
    # };
  };

}
