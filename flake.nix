{
  outputs = inputs:
    {
      devenvModules = { ... }:
        {
          imports = [
            ./modules/common.nix
            ./modules/sops.nix
            ./modules/process-compose.nix
            ./languages/top-level.nix
          ];
        };
    };
}
