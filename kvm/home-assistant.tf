resource "libvirt_domain" "home-assistant" {
    name = "home-assistant"
    vcpu = 2
    memory = 2048
    firmware = "/nix/store/hqz3ismqvp5ydbz377pkhggp7400pj5i-qemu-10.1.0/share/qemu/edk2-x86_64-code.fd"
    disk {
        volume_id = libvirt_volume.home-assistant.id
    }
    network_interface {
        # network_id = libvirt_network.bridge.id
        bridge = "kvm0"
    }
    qemu_agent = true
    autostart = true
}

resource "libvirt_volume" "home-assistant" {
    name = "home-assistant"
    pool = "default"
    source = "${path.root}/.terraform/tmp/haos_ova-16.2.qcow2"
    depends_on =  [ null_resource.home-assistant_prepare_image ]
}

resource "null_resource" "home-assistant_prepare_image" {
    provisioner "local-exec" {
        working_dir = "${path.root}/.terraform/tmp/"
        command = "curl -L https://github.com/home-assistant/operating-system/releases/download/16.2/haos_ova-16.2.qcow2.xz | xz -cd > haos_ova-16.2.qcow2 && qemu-img resize haos_ova-16.2.qcow2 1T"
    }
}