{ config, lib, pkgs, ... }:
let
  cfg = config.software.xmonad;
in {
  options = {
    software.xmonad = {
      enable = lib.mkEnableOption "custom XMonad (window manager)";

      config = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = ../../config/xmonad/xmonad.hs;
        description = "The path of the XMonad configuration file. This file is embedded in the binary.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      autorun = true;
      displayManager.defaultSession = "none+xmonad";
      windowManager.xmonad = {
        enable = true;
        config = cfg.config;
        enableContribAndExtras = true;
      };
    };
  };
}