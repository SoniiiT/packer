# anatomy.md

> Auto-maintained by OpenWolf. Last scanned: 2026-09-21T16:32:36.894Z
> Files: 25 tracked | Anatomy hits: 0 | Misses: 0

> Project structure index. Auto-maintained by OpenWolf hooks and daemon.
> Run `openwolf scan` to generate, or wait for the first Claude Code session.
> Status: Pending initial scan

## ./

- `.gitignore` — Git ignore rules (~41 tok)
- `AGENTS.md` — OpenWolf (~75 tok)
- `CLAUDE.md` — OpenWolf (~99 tok)
- `README.md` — Project documentation (~750 tok)

## .github/workflows/

- `packer-proxmox.yml` — CI: Packer Build on Proxmox (~1318 tok)

## Proxmox/Ubuntu-24.04.02/

- `ubuntu-server-24.04.02.pkr.hcl` — Ubuntu Server jammy (~1237 tok)

## Proxmox/Ubuntu-24.04.02/files/

- `99-pve.cfg` (~11 tok)

## Proxmox/Ubuntu-24.04.02/http/

- `meta-data` (~0 tok)
- `user-data` — cloud-config (~356 tok)

## Proxmox/Ubuntu-24.04.03/

- `ubuntu-server-24.04.02.pkr.hcl` — Ubuntu Server jammy (~1237 tok)

## Proxmox/Ubuntu-24.04.03/files/

- `99-pve.cfg` (~11 tok)

## Proxmox/Ubuntu-24.04.03/http/

- `meta-data` (~0 tok)
- `user-data` — cloud-config (~356 tok)

## Proxmox/Windows-Server-2022-Datacenter/

- `windows-server.pkr.hcl` — Windows Server 2022 Datacenter (~1345 tok)

## Proxmox/Windows-Server-2022-Datacenter/files/

- `autounattend.xml` (~2678 tok)
- `enable-winrm.ps1` — Enable WinRM for Packer (~606 tok)

## Proxmox/Windows-Server-2022-Standard/

- `windows-server.pkr.hcl` — Windows Server 2022 Standard (~1342 tok)

## Proxmox/Windows-Server-2022-Standard/files/

- `autounattend.xml` (~2678 tok)
- `enable-winrm.ps1` — Enable WinRM for Packer (~606 tok)

## Proxmox/Windows-Server-2025-Datacenter/

- `windows-server.pkr.hcl` — Windows Server 2025 Datacenter (~1434 tok)

## Proxmox/Windows-Server-2025-Datacenter/files/

- `autounattend.xml` (~3156 tok)
- `enable-winrm.ps1` — Enable WinRM for Packer (~606 tok)

## Proxmox/Windows-Server-2025-Standard/

- `windows-server.pkr.hcl` — Windows Server 2025 Standard (~1430 tok)

## Proxmox/Windows-Server-2025-Standard/files/

- `autounattend.xml` (~3156 tok)
- `enable-winrm.ps1` — Enable WinRM for Packer (~606 tok)
