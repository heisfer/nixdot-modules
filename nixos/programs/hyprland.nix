{
  config,
  lib,
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.dotmod.types) hyprlang;
  inherit (lib.dotmod.generators) toHyprlang;
  cfg = config.programs.hyprland;
in
{
  options.programs.hyprland = {
    settings = mkOption {
      type = hyprlang;
      description = "Hyprland configuration value";
      default = { };
    };
  };
  config = mkIf cfg.enable {
    environment.etc."xdg/hypr/hyprland.conf" = mkIf (cfg.settings != { }) {
      text = toHyprlang { inherit (cfg) settings; };
    };
  };
}
