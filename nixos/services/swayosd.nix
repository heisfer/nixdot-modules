{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkPackageOption mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe';
  inherit (lib.types)
    nullOr
    either
    lines
    path
    ;
  cfg = config.services.swayosd;

  tomlFormat = pkgs.formats.toml { };
in
{

  options.services.swayosd = {
    enable = mkEnableOption "SwayOSD";
    package = mkPackageOption pkgs "swayosd" { };

    backend = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "SwayOSD backend settings";
    };

    config = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "SwayOSD backend settings";
    };

    style = mkOption {
      type = either path lines;
      description = "SwayOSD style";
      default = ''
        window#osd {
          padding: 12px 20px;
          border-radius: 999px;
          border: none;
          background: alpha(@theme_bg_color, 0.8); }
          window#osd #container {
            margin: 16px; }
          window#osd image,
          window#osd label {
            color: @theme_fg_color; }
          window#osd progressbar:disabled,
          window#osd image:disabled {
            opacity: 0.5; }
          window#osd progressbar {
            min-height: 6px;
            border-radius: 999px;
            background: transparent;
            border: none; }
          window#osd trough {
            min-height: inherit;
            border-radius: inherit;
            border: none;
            background: alpha(@theme_fg_color, 0.5); }
          window#osd progress {
            min-height: inherit;
            border-radius: inherit;
            border: none;
            background: @theme_fg_color; }
      '';
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];

    #backend
    systemd.services.swayosd-libinput-backend = {
      description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
      documentation = [ "https://github.com/ErikReider/SwayOSD" ];
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
      after = [ "graphical.target" ];

      serviceConfig = {
        Type = "dbus";
        BusName = "org.erikreider.swayosd";
        ExecStart = getExe' cfg.package "swayosd-libinput-backend";
        Restart = "on-failure";
      };
    };

    # User Service
    systemd.user.services.swayosd = {
      description = "Swayosd frontend server";
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = getExe' cfg.package "swayosd-server";
        Restart = "always";
        RestartSec = "5s";
      };
      wantedBy = [ "graphical-session.target" ];
    };

    environment.etc = {
      "xdg/swayosd/backend.toml" = mkIf (cfg.backend != { }) {
        text = tomlFormat.generate "swayosd-backend" cfg.backend;
      };
      "xdg/swayosd/config.toml" = mkIf (cfg.config != { }) {
        text = tomlFormat.generate "swayosd-config" cfg.config;
      };
      "xdg/swayosd/style.css".source =
        if builtins.isPath cfg.style || lib.isStorePath cfg.style then
          cfg.style
        else
          pkgs.writeText "swayosd-style.css" cfg.style;
    };

  };

}
