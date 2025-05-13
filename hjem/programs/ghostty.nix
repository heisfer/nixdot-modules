{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkPackageOption mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) genAttrs;

  # home-manager
  keyValueSettings = {
    listsAsDuplicateKeys = true;
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  };
  keyValue = pkgs.formats.keyValue keyValueSettings;

  cfg = config.programs.ghostty;
in
{
  options.programs.ghostty = {
    enable = mkEnableOption "ghostty";

    package = mkPackageOption pkgs "ghostty" { };

    config = mkOption {
      inherit (keyValue) type;
      default = { };

    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    hjem.users = genAttrs config.userspace.hjemUsers (user: {
      files.".config/ghostty/config" = mkIf (cfg.config != { }) {
        source = keyValue.generate "ghostty-config" cfg.config;
      };
    });
  };

}
