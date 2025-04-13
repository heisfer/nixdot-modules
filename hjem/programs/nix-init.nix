{
  config,
  lib,
  pkgs,
  ...
}:
let

  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) listOf str;
  inherit (lib.attrsets) genAttrs;

  cfg = config.programs.nix-init;

  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.nix-init = {
    enable = mkEnableOption "nix-init";

    package = mkPackageOption pkgs "nix-init" { };

    users = mkOption {
      type = listOf str;
      default = config.userspace.hjemUsers; # I have no idea how to automate this
      description = "List of users under hjem.users.<users>";
      example = [ "username" ];
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "nix-init config.toml. See https://github.com/nix-community/nix-init?tab=readme-ov-file#configuration";
      example = {
        maintainers = [ "blop" ];
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    hjem.users = genAttrs cfg.users (user: {
      files = {
        ".config/nix-init/config.toml" = mkIf (cfg.settings != { }) {
          source = tomlFormat.generate "nix-init-config" cfg.settings;
        };
      };
    });

  };

}
