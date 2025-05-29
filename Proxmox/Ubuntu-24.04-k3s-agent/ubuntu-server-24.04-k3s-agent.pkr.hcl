# Ubuntu Server jammy
# ---
# Packer Template to create an Ubuntu Server (jammy) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

# Resource Definition for the VM Template
source "proxmox-iso" "ubuntu-server-24-04-02" {
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "pve-srv-01"
    vm_id = "900"
    vm_name = "ubuntu-server-24-04-02"
    template_description = "Ubuntu Server Noble Image with K3s Agent pre-installed"

    # VM OS Settings
    # ISO Boot Settings
    boot_iso {
        iso_url = "https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
        iso_checksum = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
        iso_storage_pool = "local"
        unmount = true
    }

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "32G"
        format = "raw"
        storage_pool = "M2-Storage"
        type = "virtio"
    }

    # Second Disk for Kubernetes Data
    disks {
        disk_size = "128G"
        format = "raw"
        storage_pool = "HDD-Storage"
        type = "virtio"
    }

    # VM Socket Settings
    sockets = "1"

    # VM CPU Settings
    cores = "1"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "M2-Storage"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "./http"

    ssh_username = "soniiit"
    ssh_private_key_file = "/home/github-runner/.ssh/id_rsa"
    ssh_timeout = "60m"
}

# Build Definition to create the VM Template
build {
    name = "ubuntu-server-24-04-02"
    sources = ["source.proxmox-iso.ubuntu-server-24-04-02"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Setup Second Disk for Kubernetes
    provisioner "shell" {
        inline = [
            "parted /dev/vdb mklabel gpt",
            "parted /dev/vdb mkpart primary ext4 0% 100%",
            "mkfs.ext4 /dev/vdb1",
            "mkdir -p /mnt/kubernetes",
            "echo '/dev/vdb1 /mnt/kubernetes ext4 defaults 0 0' >> /etc/fstab",
            "mount -a"
        ]
    }

    # Install Longhorn Prerequisites
    provisioner "shell" {
        inline = [
            "apt-get update",
            "apt-get install -y nfs-common",
            "modprobe iscsi_tcp",
            "echo 'iscsi_tcp' >> /etc/modules",
            "systemctl enable iscsid",
            "systemctl start iscsid",
            "modprobe dm_crypt",
            "echo 'dm_crypt' >> /etc/modules",
            "systemctl stop multipathd multipathd.socket",
            "systemctl disable multipathd multipathd.socket"
        ]
    }

    # Install K3s Agent Binary and Dependencies
    provisioner "shell" {
        inline = [
            "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"agent\" K3S_URL=\"https://192.168.178.10:6443\" K3S_TOKEN=\"K10c260dfb82c460db11012a9267f3e248551a91a53effa63300e626bd4255407d2::server:bbc6f48b897fbeb0ebdfa21c2d6755d8\" sh -"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "./files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}