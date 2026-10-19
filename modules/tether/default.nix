{ config, lib, pkgs, ... }:
let
  cfg = config.my-config.tether;
  inherit (lib) types mkIf mkOption mkMerge;
in {
  options.my-config.tether = {
    enable = mkOption {
      description = "Enable Tether (iPhone Continuity for Linux): package, avahi discovery, firewall and tetherd user daemon";
      type = types.bool;
      default = false;
    };

    bluetooth.enable = mkOption {
      description = "Enable BlueZ experimental mode and set adapter class for Tether messages/notifications";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [ tether ];

      # iPhone discovers tetherd via Bonjour/mDNS
      services.avahi = {
        enable = true;
        openFirewall = true; # 5353/udp
        publish = {
          enable = true;
          userServices = true;
        };
      };

      # tetherd mTLS listener the iPhone connects to
      networking.firewall.allowedTCPPorts = [ 5134 ];

      # Mirrors lib/systemd/user/tetherd.service shipped with the package
      # (NixOS only installs units from `systemd.packages`, which would also
      # pull in an unpatched system template unit, so define it here instead).
      systemd.user.services.tetherd = {
        description = "Tether daemon, bridging an iPhone to this computer";
        documentation = [ "https://github.com/zackb/tether" ];
        # Not tied to graphical-session.target: tetherd runs without a Wayland
        # session, it just does not sync the clipboard when there is none.
        after = [ "dbus.socket" "network.target" "bluetooth.target" ];
        wants = [ "network.target" ];
        wantedBy = [ "default.target" ];
        # tetherd shells out to btmgmt to inspect/adjust the adapter
        path = with pkgs; [ bluez ];
        unitConfig = {
          StartLimitIntervalSec = 60;
          StartLimitBurst = 3;
        };
        serviceConfig = {
          Type = "simple";
          # A client spawns its own tetherd when none is running; it holds the
          # runtime lock, so take it over rather than fail against it.
          ExecStartPre = "-${lib.getExe' pkgs.procps "pkill"} -f ^tetherd";
          ExecStart = lib.getExe' pkgs.tether "tetherd";
          Restart = "on-failure";
          RestartSec = 3;
          # The daemon writes its own log into $XDG_STATE_HOME/tether.
          StandardOutput = "null";
          StandardError = "journal";
        };
      };
    }

    (mkIf cfg.bluetooth.enable {
      assertions = [
        {
          assertion = config.my-config.bluetooth.enable;
          message = "my-config.tether.bluetooth.enable requires my-config.bluetooth.enable = true";
        }
      ];

      hardware.bluetooth.settings.General.Experimental = true;
      # NixOS does not restart bluetoothd when main.conf changes, and the Bearer
      # API only appears once it starts with Experimental=true.
      systemd.services.bluetooth.restartTriggers = [ config.environment.etc."bluetooth/main.conf".source ];

      # bluetoothd resets the Class of Device on every start; MAP/PBAP
      # (messages, contacts) need A/V Hands-Free (major 4, minor 8).
      systemd.services.tether-btclass = {
        description = "Set Bluetooth Class of Device to A/V Hands-Free for Tether";
        documentation = [ "https://github.com/zackb/tether/blob/main/docs/BLUETOOTH.md" ];
        after = [ "bluetooth.service" ];
        partOf = [ "bluetooth.service" ];
        wantedBy = [ "bluetooth.service" ];
        path = with pkgs; [ bluez coreutils gnugrep ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          TimeoutStartSec = 60;
        };
        # btmgmt epolls its stdin before running the command, so feed it a pipe.
        script = ''
          for _ in $(seq 30); do
            hci=$(ls /sys/class/bluetooth 2>/dev/null | head -n1)
            if [ -n "$hci" ]; then
              echo | btmgmt --index "$hci" class 4 8 >/dev/null 2>&1
              if echo | btmgmt --index "$hci" info 2>/dev/null | grep -q "class 0x..0408"; then
                exit 0
              fi
            fi
            sleep 1
          done
          exit 1
        '';
      };
    })
  ]);
}
