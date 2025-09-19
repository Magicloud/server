resource "libvirt_domain" "openwrt" {
    name = "openwrt"
    vcpu = 2
    memory = 2048
    disk {
        volume_id = libvirt_volume.openwrt.id
    }
    network_interface {
        # network_id = libvirt_network.bridge.id
        bridge = "kvm0"
    }
    autostart = true
}

resource "libvirt_volume" "openwrt" {
    name = "openwrt"
    pool = "default"
    # curl -O https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/openwrt-24.10.2-x86-64-generic-ext4-combined.img.gz
    # gzip -d openwrt-24.10.2-x86-64-generic-ext4-combined.img.gz
    # qemu-img resize openwrt-24.10.2-x86-64-generic-ext4-combined.img 1T
    # qemu-img convert -f raw -O qcow2 openwrt-24.10.2-x86-64-generic-ext4-combined.img openwrt-24.10.2-x86-64-generic-ext4-combined.qcow2
    source = "/home/magicloud/src/Personal/server/kvm/openwrt-24.10.2-x86-64-generic-ext4-combined.qcow2"
    # source = "${path.root}/.terraform/tmp/openwrt-24.10.2-x86-64-generic-ext4-combined.qcow2"
    # depends_on =  [ null_resource.openwrt_prepare_image ]
}

# resource "null_resource" "openwrt_prepare_image" {
#     provisioner "local-exec" {
#         working_dir = "${path.root}/.terraform/tmp/"
#         command = "curl -L https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/openwrt-24.10.2-x86-64-generic-ext4-combined.img.gz | gzip -cd > openwrt-24.10.2-x86-64-generic-ext4-combined.img && qemu-img resize openwrt-24.10.2-x86-64-generic-ext4-combined.img 1T && qemu-img convert -f raw -O qcow2 openwrt-24.10.2-x86-64-generic-ext4-combined.img openwrt-24.10.2-x86-64-generic-ext4-combined.qcow2"
#     }
# }