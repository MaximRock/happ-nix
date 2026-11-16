# NixOS module for Happ — GUI proxy client powered by Xray core.
#
# happd runs as root and communicates with the GUI client over
# /tmp/happd.sock. Exactly one happd instance can run at a time.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.happ;
in
{
  options.services.happ = {
    enable = lib.mkEnableOption "Happ proxy client";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./happ.nix {
        inherit (cfg) forceXwayland forceSoftwareRendering;
      };
      defaultText = lib.literalExpression "pkgs.callPackage ./happ.nix { }";
      description = ''
        Happ package to use. The default is built from the bundled `happ.nix`
        with {option}`services.happ.forceXwayland` and
        {option}`services.happ.forceSoftwareRendering` applied.
      '';
    };

    forceXwayland = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Build the default package so that Happ always runs through XWayland:
        sets `QT_QPA_PLATFORM=xcb` and removes the bundled Wayland plugins.
        Has no effect when {option}`services.happ.package` is overridden.
      '';
    };

    forceSoftwareRendering = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Build the default package with software Qt/OpenGL rendering. Useful for
        VMs and systems without a working GPU driver. Has no effect when
        {option}`services.happ.package` is overridden.
      '';
    };

    tunMode = {
      enable = lib.mkEnableOption "TUN mode support for Happ";

      interface = lib.mkOption {
        type = lib.types.str;
        default = "tun0";
        description = "Name of the TUN interface used by Happ.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Happ reads the machine id via QSysInfo::machineUniqueId(); dbus-broker
    # does not create /var/lib/dbus/machine-id, which leaves the HWID empty.
    systemd.tmpfiles.rules = [
      "L+ /var/lib/dbus/machine-id - - - - /etc/machine-id"
    ];

    systemd.services.happd = {
      description = "Happ Process Control Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # The wrapper already provides these, but happd spawns child processes
      # that look up ip/iptables/ps through PATH as well.
      path = with pkgs; [
        iproute2
        iptables
        procps
        net-tools
        coreutils
      ];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Group = "root";
        ExecStart = "${cfg.package}/bin/happd";
        Restart = "always";
        RestartSec = 5;
        TimeoutStopSec = 10;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        NoNewPrivileges = false;
        StateDirectory = "happd";
      };
    };

    boot.kernelModules = lib.mkIf cfg.tunMode.enable [ "tun" ];

    networking.firewall = lib.mkIf cfg.tunMode.enable {
      checkReversePath = "loose";
      trustedInterfaces = [ cfg.tunMode.interface ];
    };
  };
}
