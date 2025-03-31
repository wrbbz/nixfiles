{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    hypr.enable = mkOption {
      description = "Enable my customized Hypr desktop";
      type = types.bool;
      default = false;
    };
    hypr.layout = mkOption {
      description = "master or dwindle layout";
      type = types.enum ["dwindle" "master"];
      default = "master";
    };
    hypr.monitors = mkOption {
      description = "Monitor setup";
      type = types.listOf types.str;
      default = [
        ",preferred,auto,auto"
      ];
    };
    hypr.workspaces = mkOption {
      description = "Workspaces setup";
      type = types.listOf types.str;
      default = [ ];
    };
    hypr.cursor.size = mkOption {
      description = "Cursor size";
      type = types.int;
      default = 32;
    };
    hypr.extraConfig = mkOption {
      description = "Extra config";
      type = types.str;
      default = "";
    };
    hypr.paperConfig = mkOption {
      description = "Wallpapers setup";
      type = types.str;
      default = ''
        ipc = off
        splash = off
        preload = /home/wrbbz/.pictures/bg.png
        wallpaper = ,contain:/home/wrbbz/.pictures/bg.png
        '';
    };
  };

  # if my-config.template.desktop.gnome.enable is set to true
  # set the following options
  config = mkIf config.my-config.hypr.enable {
    security.pam.services.hyprlock = {};

    programs.dconf.enable = true;

    # Enable sound.
    # sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      config.common.default = "xdg-desktop-portal-hyprland";
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gnome
      ];
    };

    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        brightnessctl
        hyprland-per-window-layout
        hyprlock
        hyprpaper
        hyprpicker
        notify-desktop
        pulsemixer
        swaynotificationcenter
        wireplumber
        wl-clipboard
        xdg-utils
        (writeShellApplication {
          name = "hypr-screenshot";
          runtimeInputs = [
            slurp # Select a region in a Wayland compositor | used for screenshots
            grim # take screenshots
          ];
          text = (builtins.readFile ./screenshot.sh);
        })
      ];

      home.sessionVariables = {
        QT_QPA_PLATFORM = "wayland";
        NIXOS_OZONE_WL = "1";
      };

      gtk = {
        enable = true;
        font = { name = "sans-serif"; };
        theme = {
          name = "Adwaita";
          package = pkgs.gnome-themes-extra;
        };
        iconTheme = {
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
        };
        cursorTheme = {
          package = pkgs.nordzy-cursor-theme;
          name = "Nordzy-cursors";
          size = config.my-config.hypr.cursor.size;
        };
      };

      home.pointerCursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-cursors";
        gtk.enable = true;
        size = config.my-config.hypr.cursor.size;
      };

      home.file = {
        "./.config/electron25-flags.conf".text = ''
        --enable-features=WaylandWindowDecorations
        --ozone-platform-hint=auto
        '';
      };

      home.file = {
        "./.config/electron13-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
        '';
      };

      # TODO: take a look at https://github.com/Duckonaut/split-monitor-workspaces
      wayland.windowManager.hyprland = {
        enable = true;
        xwayland = {
          enable = true;
        };
        systemd.enable = true;
        settings = {
          monitor = config.my-config.hypr.monitors;
          xwayland = {
            force_zero_scaling = true;
          };

          input = {
            kb_layout = "us,ru";
            kb_options = "grp:caps_toggle,grp_led:caps";
            follow_mouse = 1;
            touchpad = {
              natural_scroll = true;
              disable_while_typing = true;
              clickfinger_behavior = true;
            };
            sensitivity = 0;
          };
          gestures = {
            workspace_swipe = true;
          };

          workspace = config.my-config.hypr.workspaces;

          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" = "rgba(595959aa)";

            layout = "${config.my-config.hypr.layout}";
          };

          decoration = {
            rounding = 5;
            blur = {
              enabled = "yes";
              size = 3;
              passes = 1;
              new_optimizations = "on";
            };
            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };
          };
          animations = {
            enabled = "yes";
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            disable_autoreload = true;
          };

          dwindle = {
            pseudotile = "yes";
            preserve_split = "yes";
          };
          master = {
            new_status = "slave";
            orientation = "center";
            allow_small_split = true;
            slave_count_for_center_master = 0;
          };

          "$mainMod" = "SUPER";

          bind = [
            "$mainMod, Return, exec, alacritty msg create-window || alacritty"
            "$mainMod, Space, exec, wofi --dmenu --show run"
            "$mainMod, P, exec, tessen --dmenu wofi --action autotype"
            "$mainMod, V, exec, rofi-rbw"
            "$mainMod, E, exec, rofimoji"
            "$mainMod SHIFT, E, exec, rofi -show emoji"
            "$mainMod SHIFT, C, killactive,"
            "$mainMod SHIFT, Q, exec, hyprlock"
            "$mainMod, Q, exec, qutebrowser"
            "$mainMod ALT, F, togglefloating,"
            "$mainMod ALT, C, centerwindow,"
            "$mainMod, F, fullscreen, 0"
            "$mainMod SHIFT, F, fullscreenstate, -1 1"

            # Move windows
            "$mainMod SHIFT, H, swapwindow, l"
            "$mainMod SHIFT, L, swapwindow, r"
            "$mainMod SHIFT, K, swapwindow, u"
            "$mainMod SHIFT, J, swapwindow, d"

            # Move focus with mainMod + hjkl
            "$mainMod, H, movefocus, l"
            "$mainMod, L, movefocus, r"
            "$mainMod, K, movefocus, u"
            "$mainMod, J, movefocus, d"

            # Move focus to another monitor
            "$mainMod, I, focusmonitor, l"
            "$mainMod, O, focusmonitor, r"

            # Move window to anothe monitor
            "$mainMod SHIFT, I, movewindow, mon:l"
            "$mainMod SHIFT, O, movewindow, mon:r"

            # Cycle workspaces
            "$mainMod ALT, J, workspace, +1"
            "$mainMod ALT, K, workspace, -1"
            "$mainMod SHIFT ALT, J, movetoworkspace, +1"
            "$mainMod SHIFT ALT, K, movetoworkspace, -1"

            # Switch workspaces with mainMod + [0-9]
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"

            # Move active window to a workspace with mainMod + SHIFT + [0-9]
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"

            # Scroll through existing workspaces with mainMod + scroll
            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"

            # Media keys
            ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ toggle"
            "$mainMod, M, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessDown, exec, brightnessctl set '5%-'"
            ",XF86MonBrightnessUp, exec, brightnessctl set '+5%'"

            # Color picker
            "$mainMod ALT, P, exec, hyprpicker --autocopy --no-fancy"

            # Screenshots
            "$mainMod, S, exec, TO_FILE=false FULL_SCREEN=true hypr-screenshot"
            "$mainMod ALT, S, exec, TO_FILE=true FULL_SCREEN=true hypr-screenshot"
            "$mainMod SHIFT, S, exec, TO_FILE=false FULL_SCREEN=false hypr-screenshot"
            "$mainMod SHIFT ALT, S, exec, TO_FILE=true FULL_SCREEN=false hypr-screenshot"

            # Notifications
            "$mainMod, N, exec, swaync-client --toggle-panel"
            "$mainMod, D, exec, swaync-client --toggle-dnd"

          ];

          # Move/resize windows with mainMod + LMB/RMB and dragging
          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];

          exec-once = [
            # Notifications
            "${pkgs.swaynotificationcenter}/bin/swaync"

            # Keyboard layout per window
            "${pkgs.hyprland-per-window-layout}/bin/hyprland-per-window-layout"

            # Wallpaper
            "${pkgs.hyprpaper}/bin/hyprpaper"
          ];
          env = [
            "HYPRCURSOR_THEME,Nordzy-cursors"
            "HYPRCURSOR_SIZE,${toString config.my-config.hypr.cursor.size}"
          ];
        };
        extraConfig = config.my-config.hypr.extraConfig;
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          background = [
            {
              monitor = "";
              path = "~/.pictures/lock.png";
            }
          ];
          general = {
            no_fade_in = false;
            grace = 0;
            disable_loading_bar = false;
          };
          # Profile photo
          image = {
            monitor = "";
            path = "~/pictures/avatar.jpg";
            border_size = 2;
            border_color = "rgba(60, 56, 54, 1)";
            size = 100;
            rounding = -1;
            rotate = 0;
            reload_time = -1;
            reload_cmd = "";
            position = "0, 200";
            halign = "center";
            valign = "center";
          };
          label = [
            { # Name of the user
              monitor = "";
              text = "Arsenii Zorin";
              color = "rgba(251, 241, 199, 0.9)";
              outline_thickness = 0;
              dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
              dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
              dots_center = true;
              font_size = 20;
              font_family = "SF Pro Display Bold";
              position = "0, 110";
              halign = "center";
              valign = "center";
            }
            { # Time
              monitor = "";
              text = "cmd[update:1000] echo \"<span>$(date +\"%H:%M\")</span>\"";
              color = "rgba(251, 241, 199, 0.9)";
              font_size = 60;
              font_family = "SF Pro Display Bold";
              position = "0, -8";
              halign = "center";
              valign = "center";
            }
            { # Day-Month-Date
              monitor = "";
              text = "cmd[update:1000] echo -e \"$(date +\"%A, %B %d\")\"";
              color = "rgba(251, 241, 199, 0.9)";
              font_size = 19;
              font_family = "SF Pro Display Bold";
              position = "0, -60";
              halign = "center";
              valign = "center";
            }
            { # USER
              monitor = "";
              text = "    $USER";
              color = "rgba(251, 241, 199, 0.9)";
              outline_thickness = 0;
              dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
              dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
              dots_center = true;
              font_size = 16;
              font_family = "SF Pro Display Bold";
              position = "0, -190";
              halign = "center";
              valign = "center";
            }
          ];
          # USER-BOX

          shape = {
            monitor = "";
            size = "320, 55";
            color = "rgba(255, 255, 255, 0.1)";
            rounding = -1;
            border_size = 0;
            border_color = "rgba(255, 255, 255, 1)";
            rotate = 0;
            xray = false; # if true, make a "hole" in the background (rectangle of specified size, no rotation)
            position = "0, -190";
            halign = "center";
            valign = "center";
          };
          # INPUT FIELD
          input-field = {
            monitor = "";
            size = "320, 55";
            outline_thickness = 0;
            dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = true;
            outer_color = "rgba(255, 255, 255, 0)";
            inner_color = "rgba(255, 255, 255, 0.1)";
            font_color = "rgba(251, 241, 199, 1.0)";
            fade_on_empty = false;
            font_family = "SF Pro Display Bold";
            placeholder_text = "<span foreground=\"##ffffff99\">🔒  <i>Say friend and enter</i></span>";
            check_color = "rgb(7, 102, 120)";
            fail_color = "rgb(175, 58, 3)";
            fail_text = "<span foreground=\"##d7992199\"></span> <span foreground=\"##ebdbb299\"><b>Pathetic </b></span> <span foreground=\"##d7992199\"> </span>";
            fail_transition = 300;
            hide_input = false;
            position = "0, -268";
            halign = "center";
            valign = "center";
          };
        };
      };

      home.file = {
        "./.config/hypr/hyprpaper.conf".text = config.my-config.hypr.paperConfig;
      };
    };
  };
}
