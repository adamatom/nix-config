# AI coding agents, from numtide's llm-agents flake.
#
# The outer function is the flake-parts module, so it can see `inputs`
# directly; no extraSpecialArgs needed.
{ inputs, ... }:
{
  flake.modules.homeManager.ai-tools =
    { pkgs, ... }:
    let
      llmAgentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = with llmAgentPackages; [
        claude-code
        codex
        gemini-cli
        tuicr
      ];
    };
}
