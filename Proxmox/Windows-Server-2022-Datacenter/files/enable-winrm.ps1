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
    if (Test-Path "$path\guest-agent\qemu-ga-x86_64.msi") {
        Write-Host "Found VirtIO ISO at $path"
        
        # Install Guest Agent
        Write-Host "Installing QEMU Guest Agent..."
        Start-Process msiexec.exe -ArgumentList "/i $path\guest-agent\qemu-ga-x86_64.msi /qn" -Wait
        
        # Install Drivers (Network, Balloon, SCSI, Serial, etc.)
        Write-Host "Installing VirtIO Drivers..."
        pnputil /add-driver "$path\*.inf" /subdirs /install
        
        break
    }
}

Write-Host "WinRM Configured."
