{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    aerospace.enable = mkOption {
      description = "Enable aerospace";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.aerospace.enable {
    services.aerospace = {
      enable = true;
      package = pkgs.aerospace;


      settings = {
        after-login-command = [ ];
        after-startup-command = [ ];

        key-mapping.preset = "qwerty";

        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        accordion-padding = 14;

        default-root-container-layout = "tiles";
        default-root-container-orientation = "horizontal";

        exec-on-workspace-change = [
          "/bin/zsh"
          "-c"
          "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_changed FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
        ];

        on-focus-changed = [
          "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
          "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger front_app_switched"
        ];

        gaps = {
          outer = {
            top = 6;
            bottom = 6;
            left = 6;
            right = 6;
          };
          inner = {
            horizontal = 6;
            vertical = 6;
          };
        };

        on-window-detected = [
          {
            check-further-callbacks = false;
            "if" = {
              app-id = "com.tdesktop.Telegram";
            };
            run = [
              "move-node-to-workspace 2"
            ];
          }
        ];

        mode.main.binding = {
          cmd-alt-h = [ ];

          alt-tab = "workspace-back-and-forth";

          cmd-shift-f = "fullscreen";
          cmd-shift-t = "layout floating tiling";
          cmd-shift-w = "close";

          cmd-h = "focus left";
          cmd-j = "focus down";
          cmd-k = "focus up";
          cmd-l = "focus right";

          cmd-shift-enter = "exec-and-forget open -nb org.alacritty";

          cmd-shift-h = "move left";
          cmd-shift-j = "move down";
          cmd-shift-k = "move up";
          cmd-shift-l = "move right";

          ctrl-cmd-shift-0 = "balance-sizes";

          cmd-1 = "workspace 1";
          cmd-2 = "workspace 2";
          cmd-3 = "workspace 3";
          cmd-4 = "workspace 4";
          cmd-5 = "workspace 5";
          cmd-6 = "workspace 6";

          cmd-shift-1 = [
            "move-node-to-workspace 1"
            "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
          ];
          cmd-shift-2 = [
            "move-node-to-workspace 2"
            "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
          ];
          cmd-shift-3 = [
            "move-node-to-workspace 3"
            "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
          ];
          cmd-shift-4 = [
            "move-node-to-workspace 4"
            "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
          ];
          cmd-shift-5 = [
            "move-node-to-workspace 5"
            "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
          ];
          cmd-shift-6 = [
            "move-node-to-workspace 6"
            "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
          ];

          ctrl-cmd-shift-space = "layout floating tiling";
          ctrl-cmd-shift-minus = "resize smart -50";
          ctrl-cmd-shift-equal = "resize smart +50";

          alt-leftSquareBracket = "join-with left";
          alt-rightSquareBracket = "join-with right";

          alt-slash = "layout horizontal vertical";

          ctrl-cmd-shift-r = "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --reload && aerospace reload-config";
        };
      };
    };
  };
}
