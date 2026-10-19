{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkOption;
  sentry-mcp-server = pkgs.callPackage ./sentry-mcp-server/package.nix { };
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
          servers.atlassian.url = "https://mcp.atlassian.com/v1/mcp/authv2";
          servers.grafana.url = "https://mcp.grafana.com/mcp";

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
          # settings.json and ~/.claude.json stay hand-managed on purpose:
          # no `settings` declared here.
        };
      };
    nixpkgs.allowUnfreePackages = [ "claude-code" "sentry-mcp-server" ];
  };
}
