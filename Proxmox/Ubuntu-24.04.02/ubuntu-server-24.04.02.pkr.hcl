# Ubuntu Server jammy
# ---
# Packer Template to create an Ubuntu Server (jammy) on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.4"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "vm_name" {
    type    = string
    default = "ubuntu-server-24-04-02"
}

variable "vm_id" {
    type    = string
    default = "900"
}

variable "iso_url" {
    type    = string
    default = "https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
}

variable "iso_checksum" {
    type    = string
    default = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
}

# --- Variable Definitions (Change if necessary) ---

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

variable "ssh_private_key_file" {
    type = string
    default = "/home/github-runner/.ssh/id_rsa"
}

variable "proxmox_node" {
    type    = string
    default = "pve-srv-01"
}

variable "proxmox_storage" {
    type    = string
    default = "M2-Storage"
}

variable "cpu_type" {
    type    = string
    default = "host"
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server" {

    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.proxmox_node}"
    vm_id = "${var.vm_id}"
    vm_name = "${var.vm_name}"
    template_description = "Ubuntu Server Noble Image"

    # VM OS Settings
    # ISO Boot Settings
    boot_iso {
        iso_url = "${var.iso_url}"
        iso_checksum = "${var.iso_checksum}"
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
        storage_pool = "${var.proxmox_storage}"
        type = "virtio"
    }

    # VM Socket Settings
    sockets = "1"

    # VM CPU Settings
    cores = "2"
    cpu_type = "${var.cpu_type}"
    
    # VM Memory Settings
    memory = "4096" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.proxmox_storage}"

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
    # HTTP Bind settings werden von Packer automatisch verwaltet
    # http_bind_address = "192.168.178.254"
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username = "soniiit"

    # (Option 1) Add your Password here
    # ssh_password = ""
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "${var.ssh_private_key_file}"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "60m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server"
    sources = ["source.proxmox-iso.ubuntu-server"]

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