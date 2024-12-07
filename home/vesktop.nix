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
    mkOption
    literalExpression
    types
    mkIf
    mapAttrs'
    ;
  cfg = config.programs.vesktop;

  jsonFormat = pkgs.formats.json { };

in
{
  options = {
    programs.vesktop = {
      enable = mkEnableOption "vekstop";

      package = mkPackageOption pkgs "vesktop" { };

      withSystemVencord = mkEnableOption "system vencord package";

      settings = mkOption {
        type = jsonFormat.type;
        default = { };
        example = literalExpression ''
          {
            autoUpdate = false;
            autoUpdateNotification = false;
            # semi-required if you use theme
            enabledThemes = [ "theme.css" ]; 
            plugin = {
               AlwaysAnimate.enabled = true;
               WebContextMenus = {
                enabled = true;
                addBack = true;
              };
            };
          }
        '';
      };
      quickCss = lib.mkOption {
        default = null;
        type = types.nullOr (
          types.oneOf [
            types.lines
            types.path
          ]
        );
      };

      theme = mkOption {
        default = null;
        type =
          with lib.types;
          nullOr (oneOf [
            lines
            path
          ]);
      };
      themes = mkOption {
        type = types.attrsOf types.lines;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ (cfg.package.override { withSystemVencord = cfg.withSystemVencord; }) ];

    xdg.configFile =
      let
        themes = (
          mapAttrs' (
            name: value:
            lib.attrsets.nameValuePair "vesktop/themes/${name}.css" {
              text = value;
            }
          ) cfg.themes
        );

      in
      themes
      // {
        "vesktop/settings/settings.json".source = jsonFormat.generate "vesktop-settings" cfg.settings;

        "vesktop/themes/theme.css" = lib.mkIf (cfg.theme != null) {
          source =
            if builtins.isPath cfg.theme || lib.isStorePath cfg.theme then
              cfg.theme
            else
              pkgs.writeText "vesktop/themes/theme.css" cfg.theme;
        };
        "vesktop/settings/quickCss.css" = mkIf (cfg.quickCss != null) {
          source =
            if builtins.isPath cfg.quickCss || lib.isStorePath cfg.quickCss then
              cfg.quickCss
            else
              pkgs.writeText "vesktop/settings/quickCss.css" cfg.quickCss;
        };
      };

  };
}
