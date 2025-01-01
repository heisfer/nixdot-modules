{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    getExe
    ;
  tomlFormat = pkgs.formats.toml { };
  cfg = config.services.wpaperd;

in
{
  options = {
    services.wpaperd = {
      enable = mkEnableOption "wpaperd";

      package = mkPackageOption pkgs "wpaperd" { };

      settings = mkOption {
        type = tomlFormat.type;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "wpaperd/wallpaper.toml" = mkIf (cfg.settings != { }) {
        source = tomlFormat.generate "wpaperd-wallpaper" cfg.settings;
      };
    };

    systemd.user.services.wpaperd = {
      Unit = {
        Description = "Modern wallpaper daemon for Wayland";
        PartOf = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${getExe cfg.package}";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };
}
