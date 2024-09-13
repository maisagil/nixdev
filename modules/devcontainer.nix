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
      "postCreateCommand" = "git config --global url.\"https://github.com/maisagil\".insteadOf ssh://git@github.com/maisagil"; # codespace authorizes our org by https not ssh
      secrets = {
        "SOPS_AGE_KEY" = {
          "description" = "SOPS AGE KEY for encrypting secrets";
          "documentationUrl" = "https://github.com/getsops/sops";
        };
      };
      "updateContentCommand" = "";
    };
  };
}
