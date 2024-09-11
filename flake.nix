{
  outputs = inputs:
    {
      devenvModules = { ... }:
        {
          imports = [
            ./modules/common.nix
            ./modules/sops.nix
            ./modules/devcontainer.nix
            ./modules/process-compose.nix
            ./services/top-level.nix
            ./languages/top-level.nix
          ];
        };
    };
}
