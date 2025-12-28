# Enable WinRM for Packer
Write-Host "Configuring WinRM..."

# Force Network Profile to Private (to allow WinRM)
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()
foreach ($connection in $connections) {
    $connection.GetNetwork().SetCategory(1) # 1 = Private, 0 = Public
}

# Configure WinRM
cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm set winrm/config/service '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set winrm/config/service/auth '@{Basic="true"}'
cmd.exe /c winrm set winrm/config/client/auth '@{Basic="true"}'
cmd.exe /c winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
cmd.exe /c netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes

# Allow WinRM through Firewall explicitly
New-NetFirewallRule -DisplayName "Allow WinRM HTTP" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow -Profile Any

# Install QEMU Guest Agent and Drivers
$drives = Get-PSDrive -PSProvider FileSystem
foreach ($drive in $drives) {
    $path = $drive.Root
    # Check for the main driver MSI to identify the VirtIO ISO
    if (Test-Path "$path\virtio-win-gt-x64.msi") {
        Write-Host "Found VirtIO ISO at $path"
        
        # Install VirtIO Drivers via MSI
        Write-Host "Installing VirtIO Drivers (MSI)..."
        Start-Process msiexec.exe -ArgumentList "/i `"$path\virtio-win-gt-x64.msi`" /qn /norestart ADDLOCAL=ALL" -Wait
        
        # Install Guest Agent
        $agentPath = "$path\guest-agent\qemu-ga-x86_64.msi"
        if (-not (Test-Path $agentPath)) {
            $agentPath = "$path\guest-agent\qemu-ga-x64.msi"
        }

        if (Test-Path $agentPath) {
            Write-Host "Installing QEMU Guest Agent from $agentPath..."
            Start-Process msiexec.exe -ArgumentList "/i `"$agentPath`" /qn /norestart" -Wait
        } else {
            Write-Host "WARNING: QEMU Guest Agent MSI not found on ISO!"
            if (Test-Path "$path\guest-agent") {
                Get-ChildItem "$path\guest-agent" | ForEach-Object { Write-Host $_.FullName }
            }
        }
        
        break
    }
}

Write-Host "WinRM Configured."
