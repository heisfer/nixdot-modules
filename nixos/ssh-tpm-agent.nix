{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    getExe'
    ;
  cfg = config.services.ssh-tpm-agent;
in
{
  options = {
    services.ssh-tpm-agent = {
      enable = mkEnableOption "ssh-tpm-agent";
      package = mkPackageOption pkgs "ssh-tpm-agent" { };
    };
  };
  config = mkIf cfg.enable {
    systemd.services = {
      ssh-tpm-agent = {
        unitConfig = {
          ConditionEnvironment = "!SSH_AGENT_PID";
          Description = "ssh-tpm-agent service";
          Documentation = "man:ssh-agent(1) man:ssh-add(1) man:ssh(1)";
          Wants = "ssh-tpm-genkeys.service";
          After = [
            "ssh-tpm-genkeys.service"
            "network.target"
            "sshd.target"
          ];
          Requires = "ssh-tpm-agent.socket";
        };
        serviceConfig = {
          ExecStart = "${getExe' cfg.package "ssh-tpm-agent"} --key-dir /etc/ssh";
          PassEnvironment = "SSH_AGENT_PID";
          KillMode = "process";
          Restart = "always";
        };
        wantedBy = [ "multi-user.target" ];

      };
      ssh-tpm-genkeys = {
        description = "SSH TPM Key Generation";
        unitConfig = {
          ConditionPathExists = [
            "|!/etc/ssh/ssh_tpm_host_ecdsa_key.tpm"
            "|!/etc/ssh/ssh_tpm_host_ecdsa_key.pub"
            "|!/etc/ssh/ssh_tpm_host_rsa_key.tpm"
            "|!/etc/ssh/ssh_tpm_host_rsa_key.pub"
          ];
        };
        serviceConfig = {
          ExecStart = "${getExe' cfg.package "ssh-tpm-keygen"} -A";
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
      };
    };
    systemd.sockets.ssh-tpm-agent = {
      description = "SSH TPM agent socket";
      documentation = [
        "man:ssh-agent(1)"
        "man:ssh-add(1)"
        "man:ssh(1)"
      ];
      socketConfig = {
        ListenStream = "/run/ssh-tpm-agent.sock";
        SocketMode = "0600";
        Service = "ssh-tpm-agent.ssh";
      };
      wantedBy = "sockets.target";
    };

  };

}
