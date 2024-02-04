{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    alacritty.enable = mkOption {
      description = "Enable my customized alacritty terminal emulator";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.alacritty.enable {
    home-manager.users.wrbbz = {
      programs.alacritty = {
        enable = true;
        settings = {
        # Not sure is this is still needed
        #
        # This value is used to set the `$TERM` environment variable for
        # each instance of Alacritty. If it is not present, alacritty will
        # check the local terminfo database and use 'alacritty' if it is
        # available, otherwise 'xterm-256color' is used.
        env.TERM = "xterm-256color";
        window = {
          padding = {
            x = 10;
            y = 2;
          };
          decorations = "None";
          dynamic_title = true;
          dynamic_padding = true;
        };
        cursor = {
          unfocused_hollow = true;
        };
        keyboard.bindings = [
          {
            key = "PageUp";
            mods = "Shift";
            action = "ScrollPageUp";
          }
          {
            key = "PageDown";
            mods = "Shift";
            action = "ScrollPageDown";
          }
          {
            key = "End";
            mods = "Shift";
            action = "ScrollToBottom";
          }
          {
            key = "Home";
            mods = "Shift";
            action = "ScrollToTop";
          }
        ];
        colors = {
          primary = {
            background = "#282828";
            foreground = "#ebdbb2";
          };
          normal = {
            black = "#282828";
            red = "#cc241d";
            green = "#98971a";
            yellow = "#d79921";
            blue = "#458588";
            magenta = "#b16286";
            cyan = "#689d6a";
            white = "#a89984";
          };
          bright = {
            black = "#928374";
            red = "#fb4934";
            green = "#b8bb26";
            yellow = "#fabd2f";
            blue = "#83a598";
            magenta = "#d3869b";
            cyan = "#8ec07c";
            white = "#ebdbb2";
          };
          dim = {
            black = "#32302f";
            red = "#9d0006";
            green = "#79740e";
            yellow = "#b57614";
            blue = "#076678";
            magenta = "#8f3f71";
            cyan = "#427b58";
            white = "#928374";
          };
        };
      };
    };
  };
};
}
