variable "proxmox_url" {
  type    = string
  default = "https://192.168.178.6:8006/api2/json"  # Ihre Standard Proxmox URL
}

variable "proxmox_username" {
  type    = string
  default = "packer@pam!packer"  # Standard Proxmox Username
}

variable "proxmox_node" {
  type    = string
  default = "pve-srv-01"  # Ihr Standard Proxmox Node Name
}

# Das Passwort wird über eine Umgebungsvariable gesetzt
variable "proxmox_password" {
  type      = string
  sensitive = true
  # Liest den Wert aus der Umgebungsvariable PKR_VAR_proxmox_password
} 