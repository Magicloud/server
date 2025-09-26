{ pkgs, lib, ...}: {
  home.stateVersion = "25.11";
  home.username = "magicloud";
  home.homeDirectory = "/home/magicloud";

  home.packages = with pkgs;
    [ uutils-coreutils-noprefix vscodium git git-lfs zsh libxml2 kubectl kubeseal kubernetes-helm p7zip virt-manager ansible terraform vimPlugins.vim-solarized8 gnupg starship nerdctl jq yq libcamera pkg-config clangStdenv clang ];
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
      oh-my-zsh = {
        enable = true;
        plugins = ["colorize" "command-not-found" "gitfast" "history" "history-substring-search" "rsync" "ssh-agent" "sudo" "systemd"];
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
    ZSH_THEME = "random";
    PATH = "$HOME/.cargo/bin:$HOME/.local/bin:$PATH";
    LD_LIBRARY_PATH = "${pkgs.openvino}/runtime/lib/intel64/:$LD_LIBRARY_PATH";
    LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.libclang.lib ];
    PKG_CONFIG_PATH = (builtins.concatStringsSep ":" (builtins.map (a: ''${a}/lib/pkgconfig'') [
      # pkgs.postgresql pkgs.openssl.dev pkgs.leptonica pkgs.tesseract4  pkgs.libtorch-bin
      pkgs.onnxruntime.dev pkgs.libcamera.dev pkgs.openssl.dev pkgs.opencv4WithoutCuda pkgs.libclang
    ]));
#    LIBTORCH = "${pkgs.libtorch-bin.dev}";
    RUSTFLAGS = (builtins.concatStringsSep " " (builtins.map (a: ''-L ${a}/lib'') [
      pkgs.postgresql # pkgs.openssl.dev # pkgs.leptonica pkgs.tesseract4 pkgs.opencv4WithoutCuda pkgs.libtorch-bin
    ]));
    BINDGEN_EXTRA_CLANG_ARGS = (builtins.concatStringsSep " " ((builtins.map (a: ''-I"${a}/include"'') [
      pkgs.postgresql # pkgs.glibc.dev pkgs.openssl.dev pkgs.leptonica pkgs.tesseract4 pkgs.opencv4WithoutCuda pkgs.libtorch-bin.dev
    ]) ++ [
      ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
#      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
#      ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
    ]));
  };

  imports = [
    "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;
}

