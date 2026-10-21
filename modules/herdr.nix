# herdr terminal workspace for coding agents, from numtide's llm-agents flake.
# Only config.toml is managed; herdr keeps its plugins, sessions and logs in
# the same directory as runtime state.
{ inputs, ... }:
{
  flake.modules.homeManager.herdr =
    { pkgs, ... }:
    {
      programs.herdr = {
        enable = true;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
        settings = {
          onboarding = false;
          theme = {
            name = "terminal";
            auto_switch = false;
          };
          ui = {
            agent_panel_sort = "spaces";
            sound.enabled = false;
          };
        };
      };
    };
}
