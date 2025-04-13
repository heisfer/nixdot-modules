# CREDIT:
# https://github.com/NixOS/nixpkgs/issues/280041#issuecomment-2474583192

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.services.swayosd;
in
{

  options.services.swayosd = {
    enable = mkEnableOption "swayosd services";
    package = mkPackageOption pkgs "swayosd" { };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];

    systemd.services.swayosd-libinput-backend = {
      description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
      documentation = [ "https://github.com/ErikReider/SwayOSD" ];
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
      after = [ "graphical.target" ];

      serviceConfig = {
        Type = "dbus";
        BusName = "org.erikreider.swayosd";
        ExecStart = "${cfg.package}/bin/swayosd-libinput-backend";
        Restart = "on-failure";
      };
    };

  };
}
