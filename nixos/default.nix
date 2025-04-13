{
  imports = [
    ./programs/euwebid.nix
    ./programs/kdiskmark.nix
    ./programs/hyprnotify.nix
    ./programs/waybar.nix

    ./services/ath11k.nix
    ./services/swayosd.nix
    ./services/ssh-tpm-agent.nix
    ./services/hypridle.nix

    ./ui/gtk.nix
  ];
}
