{ pkgs, lib, ...}: {
  home.stateVersion = "25.11";
  home.username = "magicloud";
  home.homeDirectory = "/home/magicloud";

  home.packages = with pkgs;
    [ vscodium git git-lfs zsh libxml2 kubectl kubeseal kubernetes-helm p7zip terraform vimPlugins.vim-solarized8 gnupg starship nerdctl jq yq libcamera pkg-config jujutsu protobuf protolint openapi-generator-cli step-cli musl.dev (lib.hiPrio gcc) clang cilium-cli bpftrace awscli2 ];
  home.file.".toprc".source = /mnt/data/dotfiles/toprc;
  home.file.".vimrc".source = /mnt/data/dotfiles/vimrc;
  home.file.".gitconfig".source = /mnt/data/dotfiles/gitconfig;
  programs = {
    home-manager.enable = true;
    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ vim-lastplace ];
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = ["colorize" "command-not-found" "gitfast" "history" "history-substring-search" "rsync" "ssh-agent" "sudo" "systemd" "emotty" ];
      };
      initContent = lib.mkOrder 1500 ''
        # . ~/.local/lib/python3.12/site-packages/powerline/bindings/zsh/powerline.zsh
        eval "$(starship init zsh)"
        . /mnt/data/dotfiles/functions.zsh
        . ~/src/Git/zsh-dircolors-solarized/zsh-dircolors-solarized.zsh

        once_a_day 'systemctl list-units --failed'
      '';
      shellAliases = {
        cp = "cp -i ";
        d = "aria2c -c -s10 -x10 ";
        dd = "dd status=progress ";
        df = "df -h ";
        free = "free -m ";
        g = "grep -Pin --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,target,.terraform} ";
        ghc = "ghc -tmpdir=/tmp -odir=/tmp -hidir=/tmp -ddump-types -Wall -ddump-splices -ddump-deriv ";
        lf = "find -type f ! -path '*/.*' ";
        ls = "ls -Fh --color=auto --group-directories-first ";
        mv = "mv -i ";
        ps = "ps fu -Aj ";
        rm = "rm -v ";
        ssh = "ssh -XYC -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc ";
        cps = "cp -ruv ";
        xmllint = "xmllint --format ";
        proxy = "http_proxy=http://192.168.0.102:8080 https_proxy=http://192.168.0.102:8080 ";
        tfi = "terraform init ";
        tfa = "terraform apply ";
        tfp = "terraform plan ";
        tfd = "terraform destroy ";
        tff = "terraform fmt ";
        tfs = "terraform state ";
      };
    };
  };
  home.sessionVariables = {
    SCCACHE_BUCKET = "sccache";
    SCCACHE_REGION = "auto";
    SCCACHE_ENDPOINT = "minio.magicloud.lan:443";
    SCCACHE_S3_ENABLE_VIRTUAL_HOST_STYLE = "true";
    SCCACHE_S3_USE_SSL = "true";
    SCCACHE_S3_SERVER_SIDE_ENCRYPTION = "false";
    AWS_ACCESS_KEY_ID = "sccache";
    AWS_SECRET_ACCESS_KEY = "sccache123";
    ZSH_THEME = "random";
    EDITOR = "vim";
    PATH = "$HOME/.cargo/bin:$HOME/.krew/bin:$HOME/.local/bin:$PATH";
    LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.openssl ];
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    RUSTFLAGS = (builtins.concatStringsSep " " (builtins.map (a: ''-L ${a}/lib'') [
      pkgs.postgresql pkgs.openssl.dev # pkgs.leptonica pkgs.tesseract4 pkgs.opencv4WithoutCuda pkgs.libtorch-bin
    ]));
  };

  imports = [
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;
}

