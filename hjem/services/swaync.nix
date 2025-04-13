{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types)
    nullOr
    oneOf
    listOf
    path
    lines
    str
    ;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) isStorePath;
  inherit (lib.attrsets) genAttrs;

  cfg = config.services.swaync;

  jsonFormat = pkgs.formats.json { };

  # Uniting file path and nix json attrs;
  # jsonFormat returns path anyways.
  settingsFile =
    if builtins.isAttrs cfg.settings then
      jsonFormat.generate "config.json" cfg.settings
    else
      cfg.settings;
in
{

  options.services.swaync = {
    enable = mkEnableOption "swaync";
    package = mkPackageOption pkgs "swaynotificationcenter" { };
    users = mkOption {
      type = listOf str;
      default = config.userspace.hjemUsers;
    };
    settings = mkOption {
      default = null;
      type = nullOr (oneOf [
        path
        jsonFormat.type
      ]);
    };
    style = mkOption {
      default = null;
      type = nullOr (oneOf [
        lines
        path
      ]);
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];
    hjem.users = genAttrs cfg.users (user: {
      files = {
        ".config/swaync/config.json" = mkIf (cfg.style != null) {
          source =
            if builtins.isAttrs cfg.settings then
              jsonFormat.generate "config.json" cfg.settings
            else
              cfg.settings;
        };
        ".config/swaync/style.css" = mkIf (cfg.style != null) {
          source =
            if builtins.isPath cfg.style || isStorePath cfg.style then
              cfg.style
            else
              pkgs.writeText "swaync/style.css" cfg.style;
        };
      };
    });

    systemd = {
      packages = [ cfg.package ];
      user.services.swaync.wantedBy = [ "graphical-session.target" ];
    };
  };
}
