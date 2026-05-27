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
      description = "Workspaces setup (list of workspace_rule attrsets)";
      type = types.listOf (types.attrsOf types.anything);
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
      config.common.default = [ "hyprland" "gtk" ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
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
        gtk4.theme = {
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
        xwayland.enable = true;
        systemd.enable = true;
        settings = {
          monitor = map (m: let
            parts = lib.splitString "," m;
            get = n: if builtins.length parts > n then builtins.elemAt parts n else "";
          in {
            output   = get 0;
            mode     = let v = get 1; in if v != "" then v else "preferred";
            position = let v = get 2; in if v != "" then v else "auto";
            scale    = let v = get 3; in if v != "" then v else "auto";
          }) config.my-config.hypr.monitors;

          workspace_rule = [
            { workspace = "w[t1]"; gaps_in = 50; gaps_out = { top = 100; right = 600; bottom = 100; left = 600; }; }
          ] ++ config.my-config.hypr.workspaces;

          config = {
            xwayland.force_zero_scaling = true;
            input = {
              kb_layout  = "us,ru";
              kb_options = "grp:caps_toggle,grp_led:caps";
              follow_mouse = 1;
              touchpad = {
                natural_scroll     = true;
                disable_while_typing = true;
                clickfinger_behavior = true;
              };
              sensitivity = 0;
            };
            general = {
              gaps_in     = 5;
              gaps_out    = 20;
              border_size = 2;
              col = {
                active_border   = { colors = [ "rgba(33ccffee)" "rgba(00ff99ee)" ]; angle = 45; };
                inactive_border = "rgba(595959aa)";
              };
              layout = config.my-config.hypr.layout;
            };
            decoration = {
              rounding = 5;
              blur = {
                enabled = true;
                size    = 3;
                passes  = 1;
              };
              shadow = {
                enabled      = true;
                range        = 4;
                render_power = 3;
                color        = "rgba(1a1a1aee)";
              };
            };
            animations.enabled = true;
            misc = {
              disable_hyprland_logo    = true;
              disable_splash_rendering = true;
              disable_autoreload       = true;
            };
            dwindle.preserve_split = true;
            master = {
              new_status                 = "slave";
              orientation                = "center";
              allow_small_split          = true;
              slave_count_for_center_master = 2;
            };
            ecosystem.no_update_news = true;
          };

          curve = {
            _args = [ "myBezier" { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1 1.05 ] ]; } ];
          };
          animation = [
            { leaf = "windows";    enabled = true; speed = 7;  bezier = "myBezier"; }
            { leaf = "windowsOut"; enabled = true; speed = 7;  bezier = "default"; style = "popin 80%"; }
            { leaf = "border";     enabled = true; speed = 10; bezier = "default"; }
            { leaf = "fade";       enabled = true; speed = 7;  bezier = "default"; }
            { leaf = "workspaces"; enabled = true; speed = 6;  bezier = "default"; }
          ];

          gesture = {
            fingers   = 3;
            direction = "horizontal";
            action    = "workspace";
          };

          env = [
            { _args = [ "QMLSCENE_DEVICE"  "softwarecontext" ]; }
            { _args = [ "HYPRCURSOR_THEME" "Nordzy-cursors" ]; }
            { _args = [ "HYPRCURSOR_SIZE"  (toString config.my-config.hypr.cursor.size) ]; }
          ];
        };

        extraConfig = ''
          -- Startup
          hl.on("hyprland.start", function()
            hl.exec_cmd("${pkgs.swaynotificationcenter}/bin/swaync")
            hl.exec_cmd("${pkgs.hyprland-per-window-layout}/bin/hyprland-per-window-layout")
            hl.exec_cmd("${pkgs.hyprpaper}/bin/hyprpaper")
          end)

          -- Keybindings
          local M = "SUPER"

          hl.bind(M .. " + Return",       hl.dsp.exec_cmd("alacritty msg create-window || alacritty"))
          hl.bind(M .. " + Space",        hl.dsp.exec_cmd("wofi --dmenu --show run"))
          hl.bind(M .. " + P",            hl.dsp.exec_cmd("tessen --dmenu wofi --action autotype"))
          hl.bind(M .. " + V",            hl.dsp.exec_cmd("rofi-rbw"))
          hl.bind(M .. " + E",            hl.dsp.exec_cmd("rofimoji"))
          hl.bind(M .. " + SHIFT + E",    hl.dsp.exec_cmd("rofi -show emoji"))
          hl.bind(M .. " + SHIFT + C",    hl.dsp.window.close())
          hl.bind(M .. " + SHIFT + Q",    hl.dsp.exec_cmd("hyprlock"))
          hl.bind(M .. " + Q",            hl.dsp.exec_cmd("qutebrowser"))
          hl.bind(M .. " + ALT + F",      hl.dsp.window.float({ action = "toggle" }))
          hl.bind(M .. " + ALT + C",      hl.dsp.window.center())
          hl.bind(M .. " + T",            function()
            local win = hl.get_active_window()
            local is_floating = win and win.floating
            hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
            if not is_floating then
              hl.dispatch(hl.dsp.window.resize({ exact = true, x = 2240, y = 1240 }))
              hl.dispatch(hl.dsp.window.center())
            else
              hl.dispatch(hl.dsp.layout("swapwithmaster"))
            end
          end)
          hl.bind(M .. " + F",            hl.dsp.window.fullscreen())
          hl.bind(M .. " + SHIFT + F",    hl.dsp.window.fullscreen_state({ internal = -1, client = 1 }))

          -- Swap windows
          hl.bind(M .. " + SHIFT + H",    hl.dsp.window.swap({ direction = "l" }))
          hl.bind(M .. " + SHIFT + L",    hl.dsp.window.swap({ direction = "r" }))
          hl.bind(M .. " + SHIFT + K",    hl.dsp.window.swap({ direction = "u" }))
          hl.bind(M .. " + SHIFT + J",    hl.dsp.window.swap({ direction = "d" }))

          -- Move focus
          hl.bind(M .. " + H",  hl.dsp.focus({ direction = "l" }))
          hl.bind(M .. " + L",  hl.dsp.focus({ direction = "r" }))
          hl.bind(M .. " + K",  hl.dsp.focus({ direction = "u" }))
          hl.bind(M .. " + J",  hl.dsp.focus({ direction = "d" }))

          -- Focus / move window between monitors
          hl.bind(M .. " + I",         hl.dsp.focus({ monitor = "l" }))
          hl.bind(M .. " + O",         hl.dsp.focus({ monitor = "r" }))
          hl.bind(M .. " + SHIFT + I", hl.dsp.window.move({ monitor = "l" }))
          hl.bind(M .. " + SHIFT + O", hl.dsp.window.move({ monitor = "r" }))

          -- Cycle workspaces
          hl.bind(M .. " + ALT + J",         hl.dsp.focus({ workspace = "e+1" }))
          hl.bind(M .. " + ALT + K",         hl.dsp.focus({ workspace = "e-1" }))
          hl.bind(M .. " + SHIFT + ALT + J", hl.dsp.window.move({ workspace = "e+1" }))
          hl.bind(M .. " + SHIFT + ALT + K", hl.dsp.window.move({ workspace = "e-1" }))

          -- Switch / move to workspaces 1-10
          for i = 1, 10 do
            local key = i % 10
            hl.bind(M .. " + " .. key,         hl.dsp.focus({ workspace = i }))
            hl.bind(M .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
          end

          -- Scroll through workspaces
          hl.bind(M .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
          hl.bind(M .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

          -- Mouse drag / resize
          hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
          hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

          -- Media keys
          hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
          hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { locked = true, repeating = true })
          hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),  { locked = true })
          hl.bind(M .. " + M",             hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
          hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set '5%-'"), { locked = true, repeating = true })
          hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set '+5%'"), { locked = true, repeating = true })

          -- Color picker
          hl.bind(M .. " + ALT + P", hl.dsp.exec_cmd("hyprpicker --autocopy --no-fancy"))

          -- Screenshots
          hl.bind(M .. " + S",               hl.dsp.exec_cmd("TO_FILE=false FULL_SCREEN=true hypr-screenshot"))
          hl.bind(M .. " + ALT + S",         hl.dsp.exec_cmd("TO_FILE=true FULL_SCREEN=true hypr-screenshot"))
          hl.bind(M .. " + SHIFT + S",       hl.dsp.exec_cmd("TO_FILE=false FULL_SCREEN=false hypr-screenshot"))
          hl.bind(M .. " + SHIFT + ALT + S", hl.dsp.exec_cmd("TO_FILE=true FULL_SCREEN=false hypr-screenshot"))

          -- Notifications
          hl.bind(M .. " + N", hl.dsp.exec_cmd("swaync-client --toggle-panel"))
          hl.bind(M .. " + D", hl.dsp.exec_cmd("swaync-client --toggle-dnd"))
        '' + config.my-config.hypr.extraConfig;
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
            path = "~/.pictures/avatar.jpg";
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
            placeholder_text = "<span foreground=\"##ffffff99\">🔒  <i>$LAYOUT</i></span>";
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
