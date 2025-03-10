{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.j.audio = {
    enable = lib.mkEnableOption "Audio" // {
      default = true;
    };
  };

  config = lib.mkIf config.j.audio.enable {
    # Use Pipewire (w/ Pulseaudio + ALSA compatibility)
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
    # Enable RTKit for low-latency audio
    security.rtkit.enable = true;

    environment.systemPackages = with pkgs; [
      # Needed for pactl
      pulseaudio
    ];
  };
}
