

{ config, pkgs, ... }:
{
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Basic Packages for all PC's
  environment.systemPackages = with pkgs; [
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  git
  wget
  bitwarden-desktop
  discord
  vscodium
  kubectl
  tidal-hifi
  nh
  nixfmt 
  kdePackages.partitionmanager
  # mullvad-vpn
  awscli2
  vlc
  libreoffice-qt6-fresh
  direnv
  mesa-demos 
  qmk
  # zulu8
  zulu17
  # python312
  gnumake
  v4l-utils
  cameractrls-gtk4 
  ffmpeg
  lshw
  usbutils
  protonmail-bridge
  space-cadet-pinball
  easyeffects
  ];
  
  # nh cleaning enabling
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos";
  };

  programs.firefox.enable = true;
  programs.gamemode.enable = true;
  programs.xwayland.enable = true;
}
