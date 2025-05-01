# Packer Proxmox Templates

Dieses Repository enthält Packer-Konfigurationen für die Erstellung von VM-Templates in Proxmox. Die Templates basieren auf Ubuntu Server und sind für verschiedene Versionen verfügbar.

## Verfügbare Templates

- **Ubuntu 24.04 LTS**
  - Konfigurationsdatei: `Proxmox/Ubuntu-24.04/ubuntu-server-24.04.pkr.hcl`
  - Enthält zusätzliche Konfigurationsdateien in den Unterordnern `http/` und `files/`

- **Ubuntu 22.04 LTS**
  - Konfigurationsdatei: `Proxmox/Ubuntu-22.04/ubuntu-server-22.04.pkr.hcl`
  - Enthält zusätzliche Konfigurationsdateien in den Unterordnern `http/` und `files/`

## Verwendung

1. **Voraussetzungen**
   - Packer installiert
   - Zugriff auf einen Proxmox-Server
   - SSH-Zugriff auf den Proxmox-Server

2. **Konfiguration**
   - Tragen Sie Ihre Proxmox-Zugangsdaten in `Proxmox/credentials.pkr.hcl` ein
   - Passen Sie die Template-Konfigurationen nach Bedarf an

3. **Template erstellen**
   ```bash
   # Für Ubuntu 24.04
   cd Proxmox/Ubuntu-24.04
   packer build ubuntu-server-24.04.pkr.hcl

   # Für Ubuntu 22.04
   cd Proxmox/Ubuntu-22.04
   packer build ubuntu-server-22.04.pkr.hcl
   ```

## Sicherheitshinweise

- Die `credentials.pkr.hcl` Datei enthält sensible Informationen und sollte nicht in das Repository eingecheckt werden
- Stellen Sie sicher, dass die SSH-Schlüssel sicher aufbewahrt werden
- Überprüfen Sie regelmäßig die Sicherheitseinstellungen der erstellten Templates