# Packer Templates für Proxmox

Dieses Repository enthält Packer-Konfigurationen für die automatisierte Erstellung von VM-Templates in Proxmox.

## Struktur

```
.
├── Proxmox/
│   ├── variables.pkr.hcl         # Basis-Konfiguration (im Git)
│   ├── Ubuntu-22.04/             # Template für Ubuntu 22.04
│   └── Ubuntu-24.04/             # Template für Ubuntu 24.04
└── .github/
    └── workflows/
        └── packer.yml            # CI/CD Pipeline
```

## Erste Schritte

1. Repository klonen:
   ```bash
   git clone [repository-url]
   ```

2. Konfiguration:
   - Passen Sie bei Bedarf die Werte in `variables.pkr.hcl` an
   - Setzen Sie das Proxmox-Passwort als Umgebungsvariable:

   ```bash
   # Lokal
   export PKR_VAR_proxmox_password='IhrPasswort'
   # oder für PowerShell
   $env:PKR_VAR_proxmox_password='IhrPasswort'
   ```

3. GitHub Secrets:
   - Nur das `PROXMOX_PASSWORD` muss als Secret gesetzt werden
   - Die anderen Werte können in `variables.pkr.hcl` angepasst werden

## Lokales Testen

```bash
# Linux/Mac
export PKR_VAR_proxmox_password='IhrPasswort'
cd Proxmox/[template-ordner]
packer init .
packer validate .
packer build .

# PowerShell
$env:PKR_VAR_proxmox_password='IhrPasswort'
cd Proxmox/[template-ordner]
packer init .
packer validate .
packer build .
```

## Neues Template hinzufügen

1. Erstellen Sie einen neuen Ordner unter `Proxmox/`:
   ```bash
   mkdir Proxmox/Neues-Template
   ```

2. Fügen Sie die notwendigen Packer-Konfigurationsdateien hinzu
3. Commit und Push - die Pipeline erkennt das neue Template automatisch

## Pipeline

Die GitHub Actions Pipeline:
- Erkennt automatisch alle Template-Ordner
- Validiert alle Templates
- Baut nur geänderte Templates
- Läuft bei Push und Pull Requests
- Kann manuell getriggert werden

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
   - Tragen Sie Ihre Proxmox-Zugangsdaten in `Proxmox/variables.pkr.hcl` ein
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

- Die `variables.pkr.hcl` Datei enthält sensible Informationen und sollte nicht in das Repository eingecheckt werden
- Stellen Sie sicher, dass die SSH-Schlüssel sicher aufbewahrt werden
- Überprüfen Sie regelmäßig die Sicherheitseinstellungen der erstellten Templates