# Windows Server 2025 Datacenter
# ---
# Packer Template to create a Windows Server 2025 Datacenter on Proxmox

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

variable "proxmox_node" {
    type    = string
    default = "pve-srv-01"
}

variable "proxmox_storage" {
    type    = string
    default = "M2-Storage"
}

variable "vm_id" {
    type    = string
    default = "904"
}

variable "vm_name" {
    type    = string
    default = "windows-server-2025-datacenter"
}

variable "cpu_type" {
    type    = string
    default = "host"
}

variable "iso_url" {
    type    = string
    default = "https://go.microsoft.com/fwlink/?linkid=2345827&clcid=0x407&culture=de-de&country=de"
}

variable "iso_checksum" {
    type    = string
    # Checksum for German ISO (Get-FileHash "SERVER_EVAL_x64FRE_de-de.iso" -Algorithm SHA256)
    default = "sha256:8207A8EB94AB250C0A36432DB07CFCA11F055A8DCB504D2B7B3521D53CD85261" 
}

variable "virtio_iso_file" {
    type    = string
    default = "local:iso/virtio-win.iso"
    description = "Path to the VirtIO ISO file on Proxmox storage"
}

# Resource Definition
source "proxmox-iso" "windows-server" {
    
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.proxmox_node}"
    vm_id = "${var.vm_id}"
    vm_name = "${var.vm_name}"
    template_description = "Windows Server 2025 Template"
    
    # VM OS Settings
    os = "win11"
    machine = "q35"
    
    # ISO Boot Settings (Windows Installer)
    boot_iso {
        iso_url = "${var.iso_url}"
        iso_checksum = "${var.iso_checksum}"
        iso_storage_pool = "local"
        unmount = true
    }

    # Additional ISOs
    # 1. VirtIO Drivers (Mounted as CD-ROM)
    additional_iso_files {
        type = "sata"
        index = 1
        iso_file = "${var.virtio_iso_file}"
        iso_storage_pool = "local"
        unmount = true
    }

    # 2. Autounattend.xml (Generated CD-ROM)
    additional_iso_files {
        type = "sata"
        index = 2
        cd_files = ["./files/autounattend.xml", "./files/enable-winrm.ps1"]
        cd_label = "cidata"
        iso_storage_pool = "local"
        unmount = true
    }

    # VM System Settings
    qemu_agent = true
    
    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-single"
    
    disks {
        disk_size = "32G"
        format = "raw"
        storage_pool = "${var.proxmox_storage}"
        type = "scsi"
        cache_mode = "writeback"
        discard = true
        io_thread = true
    }

    # VM CPU Settings
    sockets = "1"
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

    # Boot Command
    # Press Enter to boot from CD if prompted
    boot_command = ["<enter><wait><enter><wait><enter>"]
    boot_wait = "10s"

    # Communicator Settings (WinRM)
    communicator = "winrm"
    winrm_username = "Administrator"
    winrm_password = "Password123!"
    winrm_use_ssl = false
    winrm_insecure = true
    winrm_timeout = "1h"
}

# Build Definition
build {
    name = "windows-server"
    sources = ["source.proxmox-iso.windows-server"]

    # Provisioner: Install Updates or Software (Optional)
    provisioner "powershell" {
        inline = [
            "Write-Host 'Installation Complete'",
            "Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version"
        ]
    }

    # Provisioner: Convert Eval to Retail (Datacenter)
    provisioner "powershell" {
        inline = [
            "Write-Host 'Converting Windows Server Evaluation to Retail (Datacenter)...'",
            "dism /online /set-edition:ServerDatacenter /productkey:D764K-2NDRG-47T6Q-P8T8W-YP6DF /accepteula"
        ]
    }

    # Provisioner: Restart after Edition Change
    provisioner "windows-restart" {
        restart_timeout = "30m"
    }

    # Provisioner: Sysprep and Shutdown
    provisioner "powershell" {
        inline = [
            "Write-Host 'Running Sysprep...'",
            "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quit /quiet",
            "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select-Object -ExpandProperty ImageState; Write-Host $imageState; if($imageState -eq 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { break } Start-Sleep -s 1 }",
            "Write-Host 'Sysprep complete. Shutting down...'",
            "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
        ]
    }
}
