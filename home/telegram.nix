{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.telegram;

in
{
  options = {
    programs.telegram = {
      enable = lib.mkEnableOption "telegram";

      package = lib.mkPackageOption pkgs "telegram-desktop" { };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

  };
}
