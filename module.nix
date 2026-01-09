{ config, lib, pkgs, ... }:

let
  cfg = config.services.doublezero;
  doublezero = pkgs.callPackage ./default.nix { };
in
{
  options.services.doublezero = {
    enable = lib.mkEnableOption "DoubleZero client daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = doublezero;
      defaultText = lib.literalExpression "pkgs.callPackage ./default.nix { }";
      description = "The doublezero package to use.";
    };

    environment = lib.mkOption {
      type = lib.types.enum [ "testnet" "mainnet" ];
      default = "testnet";
      description = "The DoubleZero network environment to connect to.";
    };

    socketPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/doublezerod/doublezerod.sock";
      description = "Path to the daemon socket file.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "doublezero";
      description = "User account under which the daemon runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "doublezero";
      description = "Group under which the daemon runs.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "-debug" ];
      description = "Extra command-line arguments to pass to doublezerod.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "DoubleZero daemon user";
    };

    users.groups.${cfg.group} = { };

    systemd.services.doublezerod = {
      description = "DoubleZero client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        RuntimeDirectory = "doublezerod";
        RuntimeDirectoryMode = "0775";
        StateDirectory = "doublezerod";
        ExecStart = lib.concatStringsSep " " ([
          "${cfg.package}/bin/doublezerod"
          "-sock-file ${cfg.socketPath}"
          "-env ${cfg.environment}"
        ] ++ cfg.extraArgs);

        # Security hardening (matching upstream service)
        AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
        NoNewPrivileges = true;

        # Additional hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
      };
    };

    # Make the CLI tool available system-wide
    environment.systemPackages = [ cfg.package ];
  };
}
