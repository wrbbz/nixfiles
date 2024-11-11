{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkDefault mkOption;
  lockConfig = {
    backgroundType = lib.types.submodule {
      options = {
        monitor = lib.mkOption {
          type = lib.types.str;
          description = "Monitor identifier";
        };
        path = lib.mkOption {
          type = lib.types.path;
          description = "Path to the background image";
        };
      };
    };
    backgroundToString = instance: ''
      background {
        monitor = ${instance.monitor}
        path = ${instance.path}
        color = rgba(25, 20, 20, 1.0)
      }
      '';
    positionAndMonitorType = lib.types.submodule {
      options = {
        monitor = lib.mkOption {
          type = lib.types.str;
          description = "Monitor identifier";
        };
        position = lib.mkOption {
          type = lib.types.str;
          description = "X&Y offsets";
        };
      };
    };
    inputToString = instance: ''
      input-field {
          monitor = ${instance.monitor}
          size = 360, 50
          outline_thickness = 3
          dots_size = 0.33 # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = false
          dots_rounding = -1 # -1 default circle, -2 follow input-field rounding
          outer_color = rgb(251, 241, 199)
          inner_color = rgb(40, 40, 40)
          font_color = rgb(251, 241, 199)
          fade_on_empty = true
          fade_timeout = 200 # Milliseconds before fade_on_empty is triggered.
          placeholder_text = Say friend & enter
          hide_input = false
          rounding = -1 # -1 means complete rounding (circle/oval)
          check_color = rgb(7, 102, 120)
          fail_color = rgb(175, 58, 3) # if authentication failed, changes outer_color and fail message color
          fail_text = <b>Pathetic </b>
          fail_transition = 300 # transition time in ms between normal outer_color and fail_color
          capslock_color = -1
          numlock_color = -1
          bothlock_color = -1 # when both locks are active. -1 means don't change outer color (same for above)
          invert_numlock = false # change color if numlock is off

          position = ${instance.position}
          halign = center
          valign = bottom
      }
    '';
     timeToString = instance: ''
       label {
           monitor = ${instance.monitor}
           text = $TIME
           color = rgba(251, 241, 199, 1.0)
           font_size = 155
           font_family = FiraCode Nerd Font Mono

           position = ${instance.position}
           halign = center
           valign = top
       }
     '';

  };
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
    hypr.lockConfig = mkOption {
      description = "Lockscreen setup";
      type = types.attrsOf (lib.types.oneOf [lockConfig.positionAndMonitorType (types.listOf lockConfig.backgroundType)]);
      default = {
        background = [
          {
            monitor = "";
            path = "/home/wrbbz/.pictures/lock.png";
          }
        ];
        input = {
          monitor = "";
          position = "0, 100";
        };
        time = {
          monitor = "";
          position = "0, -300";
        };
      };
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
        HYPRLAND_LOG_WLR = "1";
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
            drop_shadow = "yes";
            shadow_range = 4;
            shadow_render_power = 3;
            "col.shadow" = "rgba(1a1a1aee)";
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
            no_gaps_when_only = true;
          };
          master = {
            new_status = "slave";
            no_gaps_when_only = true;
            orientation = "center";
            allow_small_split = true;
            always_center_master = true;
          };

          "$mainMod" = "SUPER";

          bind = [
            "$mainMod, Return, exec, alacritty msg create-window || alacritty"
            "$mainMod, Space, exec, wofi --dmenu --show run"
            "$mainMod, P, exec, tessen --dmenu wofi --action autotype"
            "$mainMod, E, exec, rofimoji"
            "$mainMod SHIFT, E, exec, rofi -show emoji"
            "$mainMod SHIFT, C, killactive,"
            "$mainMod SHIFT, Q, exec, hyprlock"
            "$mainMod, Q, exec, qutebrowser"
            "$mainMod ALT, F, togglefloating,"
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
        };
        extraConfig = config.my-config.hypr.extraConfig;
      };

      home.file = {
        "./.config/hypr/hyprpaper.conf".text = config.my-config.hypr.paperConfig;
      };

      home.file = {
        "./.config/hypr/hyprlock.conf".text =
          lib.strings.concatStrings [
            "${lib.concatStrings (map lockConfig.backgroundToString config.my-config.hypr.lockConfig.background)}"
            "${lockConfig.inputToString config.my-config.hypr.lockConfig.input}"
            "${lockConfig.timeToString config.my-config.hypr.lockConfig.time}"
          ];
      };
    };
  };
}
