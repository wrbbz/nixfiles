{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) types mkIf mkOption;
  sentry-mcp-server = pkgs.callPackage ./sentry-mcp-server/package.nix { };
  # humanizer-ru calls `python <skill dir>/scripts/...`; no python on PATH here,
  # so pin the interpreter to a store path instead (scripts are stdlib-only).
  humanizer-ru = pkgs.runCommand "humanizer-ru-skill" { } ''
    cp -r ${inputs.humanizer-ru}/skills/humanizer-ru $out
    chmod -R u+w $out
    substituteInPlace $out/SKILL.md \
      --replace-fail 'python <папка навыка>' '${pkgs.python3}/bin/python <папка навыка>'
  '';
in {
  options.my-config = {
    claude.enable = mkOption {
      description = "Enable claude-code";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.claude.enable {
    home-manager.users.wrbbz =
      # Function form so we can reference config.sops.secrets.*.path
      { config, ... }:
      {
        # Corporate Sentry host and a user auth token for the MCP server.
        # Both stay out of the Nix store; home-manager wraps the command in a
        # script that reads them at startup.
        sops.secrets."sentry_host" = {
          sopsFile = ../../secrets/claude.yaml;
          key = "sentry_host";
        };
        sops.secrets."sentry_mcp_token" = {
          sopsFile = ../../secrets/claude.yaml;
          key = "sentry_mcp_token";
        };

        programs.mcp = {
          enable = true;

          servers.glab = {
            command = lib.getExe pkgs.glab;
            args = [ "mcp" "serve" ];
          };
          servers.atlassian.url = "https://mcp.atlassian.com/v2/mcp";
          servers.grafana.url = "https://mcp.grafana.com/mcp";
          servers.cloudflare.url = "https://mcp.cloudflare.com/mcp";
          servers.slack = {
            url = "https://mcp.slack.com/mcp";
            oauth = {
              clientId = "1601185624273.8899143856786";
              callbackPort = 3118;
            };
          };

          servers.sentry = {
            # Built from the npm tarball with a vendored lockfile, see
            # ./sentry-mcp-server. `--host` is a CLI flag, not an env var, so a
            # tiny shell shim turns the sops-provided SENTRY_HOST into the flag.
            command = toString (
              pkgs.writeShellScript "sentry-mcp" ''
                exec ${lib.getExe sentry-mcp-server} --host="$SENTRY_HOST" "$@"
              ''
            );
            env = {
              SENTRY_HOST.file = config.sops.secrets."sentry_host".path;
              SENTRY_ACCESS_TOKEN.file = config.sops.secrets."sentry_mcp_token".path;
              MCP_SKILLS = "inspect";
            };
          };
        };

        programs.claude-code = {
          enable = true;
          # Pull programs.mcp.servers into Claude Code (delivered as the
          # generated "hm" plugin, tools named mcp__plugin_hm_<server>__*).
          enableMcpIntegration = true;
          # Skill repos pinned as non-flake inputs.
          skills = {
            # Only SKILL.md is linked; it references no other repo files.
            humanizer = "${inputs.humanizer}/SKILL.md";
            # Whole skill directory (patched, see let-binding): loads references/, runs scripts/.
            humanizer-ru = "${humanizer-ru}";
            # Whole skill directory: SKILL.md loads files from references/.
            writing-technical-docs = "${inputs.rfc-skills}/skills/writing-technical-docs";
          };
          # settings.json and ~/.claude.json stay hand-managed on purpose:
          # no `settings` declared here.
        };
      };
    nixpkgs.allowUnfreePackages = [ "claude-code" "sentry-mcp-server" ];
  };
}
