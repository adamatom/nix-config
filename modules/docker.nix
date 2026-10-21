# Docker, with adam in the docker group so it works without sudo.
{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;
    users.users.adam.extraGroups = [ "docker" ];
  };
}
