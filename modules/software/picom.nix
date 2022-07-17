{ config, lib, pkgs, ... }:
let
  cfg = config.software.picom;
in {
  options = {
    software.picom = {
      enable = lib.mkEnableOption "custom picom (compositor)";

      package = lib.mkPackageOption pkgs "picom" {};

      config = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = ../../config/picom/picom.conf;
        description = "The path of the picom configuration file.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [ cfg.package ];
      etc."xdg/picom.conf" = lib.mkIf (cfg.config != null) {
        text = builtins.readFile cfg.config;
      };
    };
  };
}