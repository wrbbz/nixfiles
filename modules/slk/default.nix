{ config, lib, pkgs, inputs, isDarwin ? false, ... }:
let
  inherit (lib) types mkIf mkOption;

  themeName = "Gruvbox Dark";

  # Same palette as modules/alacritty. slk's UI needs a few surface tones
  # alacritty has no slot for (surface_dark, border); those come from the
  # canonical gruvbox palette (bg0_hard, bg2).
  gruvboxTheme = ''
    name = "${themeName}"

    [colors]
    primary = "#83a598"      # bright blue
    accent = "#b8bb26"       # bright green
    warning = "#fabd2f"      # bright yellow
    error = "#fb4934"        # bright red
    background = "#282828"   # primary.background
    surface = "#32302f"      # dim black
    surface_dark = "#1d2021" # gruvbox bg0_hard
    text = "#ebdbb2"         # primary.foreground
    text_muted = "#928374"   # bright black
    border = "#504945"       # gruvbox bg2

    sidebar_background = "#1d2021"
    sidebar_text = "#ebdbb2"
    sidebar_text_muted = "#928374"
    rail_background = "#1d2021"

    search_highlight_bg = "#fabd2f"
    search_highlight_fg = "#282828"
  '';

  slk = inputs.slk.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    # Upstream's flake builds without ldflags, so `slk --version` says "dev".
    ldflags = (old.ldflags or [ ]) ++ [
      "-s" "-w"
      "-X main.version=${inputs.slk.shortRev or "dirty"}"
      "-X main.commit=${inputs.slk.rev or "unknown"}"
    ];
  });
in {
  options.my-config = {
    slk.enable = mkOption {
      description = "Enable slk, a Slack TUI, with the gruvbox dark theme";
      type = types.bool;
      default = false;
    };
  };

  # Function module: home-manager's own `lib` carries `lib.hm`, the NixOS one doesn't.
  config = mkIf config.my-config.slk.enable {
    home-manager.users.wrbbz = { config, lib, ... }: {
      home.packages = [ slk ];

      # Custom themes take precedence over built-ins with the same name,
      # so this replaces slk's own "Gruvbox Dark".
      xdg.configFile."slk/themes/gruvbox-dark.toml".text = gruvboxTheme;

      # slk rewrites config.toml itself (theme switcher, sidebar width,
      # workspaces), so it can't be a store symlink. Seed it once with the
      # theme selected; later edits by slk are left alone.
      home.activation.slkSeedConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cfg="${config.xdg.configHome}/slk/config.toml"
        if [ ! -e "$cfg" ]; then
          run mkdir -p "$(dirname "$cfg")"
          run printf '%s\n' '[appearance]' 'theme = "${themeName}"' > "$cfg"
        fi
      '';
    };
  };
}
