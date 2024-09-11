{
  devcontainer = {
    enable = true;
    settings = {
      features = {
        "ghcr.io/devcontainers/features/sshd:1".version = "latest";
      };
      customizations = {
        vscode = {
          extensions = [
            "mkhl.direnv"
            "vadimcn.vscode-lldb"
            "mutantdino.resourcemonitor"
            "rust-lang.rust-analyzer"
            "tamasfe.even-better-toml"
            "fill-labs.dependi"
          ];
        };
        codespaces = {
          repositories = {
            "maisagil/*" = {
              permissions = "write-all";
            };
          };
        };
      };
    };
  };
}
