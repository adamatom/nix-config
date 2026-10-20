# Sound through PipeWire, with PulseAudio and ALSA compatibility.
{
  flake.modules.nixos.pipewire = {
    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Enable sound with pipewire.
      pulseaudio.enable = false;
    };

    # Realtime scheduling for the audio server.
    security.rtkit.enable = true;
  };
}
