{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /tmp/hardware-configuration.nix
      ./users-and-groups.nix
      ./system-configuration.nix
    ];
}
