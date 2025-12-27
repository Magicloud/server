{ config, lib, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./rescue-boot.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  nix.settings.allowed-users = [ "magicloud" ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  boot = {
    kernelPackages = pkgs.linuxPackages_6_17;
    kernelParams = [ "nomodeset" ];
    loader = {
      generic-extlinux-compatible = {
        enable = true;
      };
      grub.enable = false;
      grub.devices = [ "/dev/sdi" ];
    };
    extraModprobeConfig = ''
      options zfs l2arc_noprefetch=0 l2arc_write_boost=33554432 l2arc_write_max=16777216 zfs_arc_max=2147483648
    '';
    supportedFilesystems = [ "xfs" "zfs" ];
    zfs.extraPools = [ "raid" ];
  };
  # git is needed by buildkit
  environment.systemPackages = with pkgs; [ k3s buildkit git scx.full
    ((vim-full.override { }).customize {
      vimrcConfig.customRC = ''
        set mouse=
        syntax on
        set number relativenumber
      '';
    })
  ];
  fonts.packages = [ pkgs.sarasa-gothic ];
  nixpkgs.config.allowUnfree = true;
  networking = {
#    nameservers = ["192.168.0.1"];
    proxy = {
      httpsProxy = "http://192.168.0.102:8080/";
      noProxy = "127.0.0.1,localhost,.magicloud.lan,192.168.";
    };
    useDHCP = false;
    hostId = "edeaf675";
    firewall.enable = false;
    interfaces = {
      enp3s0f0.useDHCP = false;
      enp3s0f1.useDHCP = false;
      enp4s0f0.useDHCP = false;
      enp4s0f1.useDHCP = false;
      kvm0.useDHCP = true;
    };
    bridges = {
      kvm0 = {
        interfaces = [ "enp3s0f0" ];
      };
    };
  };
  programs.zsh.enable = true;
  programs.nix-ld = {
    enable = true;
#    package = pkgs.nix-ld-rs;
  };
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
  time.timeZone = "Asia/Chongqing";
  security.pki.certificates = [ (builtins.readFile ./step.crt) ];
  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
    openssh = {
      enable = true;
      ports = [ 22 ];
    };
    xrdp = {
      enable = true;
      defaultWindowManager = "xterm";
#      extraConfDirCommands = ''
#        substituteInPlace $out/sesman.ini \
#          --replace '#SessionSockdirGroup=xrdp' SessionSockdirGroup=xrdp
#          --replace LogLevel=INFO LogLevel=DEBUG \
#          --replace LogFile=/dev/null LogFile=/var/log/xrdp-sesman.log
#        substituteInPlace $out/xrdp.ini \
#          --replace LogLevel=INFO LogLevel=DEBUG \
#          --replace LogFile=/dev/null LogFile=/var/log/xrdp.log
#      '';
    };
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
    };
  };
  users.users.magicloud = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" "kvm" "vboxusers" "xrdp" ];
    shell = pkgs.zsh;
  };
  system = {
    stateVersion = "25.11";
    autoUpgrade.enable = false;
  };
  virtualisation = {
    libvirtd = {
      enable = true;
#      extraConfig = ''
#unix_sock_group = "libvirtd"
#unix_sock_rw_perms = "0770"
#'';
#      qemu.ovmf.packages = [(pkgs.OVMF.override {
#        secureBoot = true;
#        tpmSupport = true;
#      }).fd];
    };
    virtualbox.host = {
      enable = false;
    };
    containerd = {
      enable = true;
      settings =
        let
          fullCNIPlugins = pkgs.buildEnv {
            name = "full-cni";
            paths = with pkgs;[
              cni-plugins
              cni-plugin-flannel
            ];
          };
        in {
          plugins."io.containerd.grpc.v1.cri".cni = {
#            bin_dir = "${fullCNIPlugins}/bin";
            bin_dir = "/var/lib/rancher/k3s/data/cni";
            conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
          };
          state = "/mnt/data/k3s/";
          # Optionally set private registry credentials here instead of using /etc/rancher/k3s/registries.yaml
          # plugins."io.containerd.grpc.v1.cri".registry.configs."registry.example.com".auth = {
          #  username = "";
          #  password = "";
          # };
        };
    };
    docker = {
      enable = false;
    };
  };
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      "--write-kubeconfig-mode 644"
#      "--flannel-backend none"
#      "--disable-network-policy true"
    ];
  };
  systemd.services.containerd = {
    environment = {
      HTTPS_PROXY = "http://192.168.0.102:8080/";
    };
  };
#  systemd.services.xrdp = {
#    serviceConfig = {
#      Group = lib.mkForce "root";
#      User = lib.mkForce "root";
#    };
#  };
  systemd.services.buildkitd = {
    description = "Buildkitd";
    path = [ pkgs.buildkit ];
    wants = [ "containerd.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.buildkit}/bin/buildkitd";
    };
    environment = {
      HTTPS_PROXY = "http://192.168.0.102:8080/";
    };
   };
  systemd.services.home-manager-switch = {
    description = "Daily `home-manager switch`";
    path = [ pkgs.nix ];
    environment = {
      HTTPS_PROXY = "http://192.168.0.102:8080/";
    };
    serviceConfig = {
      ExecStart = "/run/wrappers/bin/sudo -u magicloud /home/magicloud/.nix-profile/bin/home-manager switch";
    };
  };
  systemd.timers.home-manager-switch = {
    description = "Daily `home-manager switch`";
    timerConfig = {
      OnCalendar = "daily";
    };
    wantedBy = ["timers.target"];
  };
  systemd.services.rustup-upgrade = {
    description = "Daily `rustup upgrade`";
    serviceConfig = {
      ExecStart = "/run/wrappers/bin/sudo -u magicloud /home/magicloud/.cargo/bin/rustup upgrade";
    };
  };
  systemd.timers.rustup-upgrade = {
    description = "Daily `rustup upgrade`";
    timerConfig = {
      OnCalendar = "daily";
    };
    wantedBy = ["timers.target"];
  };

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--autopower" ];
  };
}
