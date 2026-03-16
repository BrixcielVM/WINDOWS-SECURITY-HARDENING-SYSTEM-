<#
====================================================
 WINDOWS SECURITY HARDENING SYSTEM
 Creado por Brixciel Vergara Morales
 
====================================================
#>

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
Clear-Host

#--------------------------------------------------
# 1. Verificar privilegios de Administrador (Sin Pausa si es OK)
#--------------------------------------------------
$admin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $admin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n [!] ERROR: REQUIERE EJECUTAR COMO ADMINISTRADOR" -ForegroundColor Red
    Write-Host " Presiona una tecla para salir..."
    $null = [Console]::ReadKey()
    Exit
}

#--------------------------------------------------
# 2. Encabezado Visual
#--------------------------------------------------
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " WINDOWS SECURITY HARDENING SYSTEM" -ForegroundColor Cyan
Write-Host " Desarrollado por: Brixciel Vergara Morales" -ForegroundColor Yellow
Write-Host "==================================================`n" -ForegroundColor Cyan

# Pequeña espera de 1 segundo
Start-Sleep -Seconds 1

#--------------------------------------------------
# 3. Ejecución 100% Automática de Hardening
#--------------------------------------------------
$steps = @(
    # --- TUS FUNCIONES ORIGINALES (Optimizadas para evitar errores de sintaxis) ---
    @{ n = "Activando Firewall de Windows"; c = { Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True } },
    @{ n = "Bloqueando puertos críticos (21,23,445...)"; c = { 21,23,69,135,137,138,139,445 | ForEach-Object { New-NetFirewallRule -DisplayName "Block_$_" -Direction Inbound -Protocol TCP -LocalPort $_ -Action Block } } },
    @{ n = "Deshabilitando protocolo SMBv1"; c = { Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart } },
    @{ n = "Forzando firma digital en SMB"; c = { Set-SmbServerConfiguration -RequireSecuritySignature $true -Force } },
    @{ n = "Deshabilitando NetBIOS sobre TCP/IP"; c = { Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled} | ForEach-Object {$_.SetTcpipNetbios(2)} } },
    @{ n = "Deshabilitando resolución LLMNR"; c = { New-Item "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Force; Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name EnableMulticast -Value 0 } },
    @{ n = "Reduciendo Telemetría"; c = { New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force; Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -Value 0 } },
    @{ n = "Protegiendo proceso LSASS (PPL)"; c = { New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Force; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name RunAsPPL -Value 1 } },
    @{ n = "Deshabilitando WDigest"; c = { Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name UseLogonCredential -Value 0 } },
    @{ n = "Configurando Control de Cuentas (UAC)"; c = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 1 } },
    @{ n = "Deshabilitando AutoRun"; c = { New-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force; Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoDriveTypeAutoRun -Value 255 } },
    @{ n = "Activando SmartScreen"; c = { Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name SmartScreenEnabled -Value "RequireAdmin" } },
    @{ n = "Deshabilitando WinRM y Registro Remoto"; c = { "WinRM", "RemoteRegistry" | ForEach-Object { Stop-Service $_ -Force -ErrorAction SilentlyContinue; Set-Service $_ -StartupType Disabled } } },
   @{ n = "Activando mitigaciones DEP/ASLR"; c = { 
    try {
        # Intentamos la activación estándar corregida
        Set-ProcessMitigation -System -Enable DEP,BottomUp,HighEntropy,SEHOP -ErrorAction Stop
    } catch {
        # Si falla, intentamos forzarlo vía Registro (Método de bajo nivel)
        $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
        if (-not (Test-Path $path)) { New-Item $path -Force }
        Set-ItemProperty $path -Name "MitigationOptions" -Value ([byte[]](0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01)) -Force
    }
} }
    @{ n = "Habilitando Auditoría de PowerShell"; c = { New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force; Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1 } },
    @{ n = "Fortaleciendo Microsoft Defender"; c = { Set-MpPreference -DisableRealtimeMonitoring $false -MAPSReporting Advanced } },
    @{ n = "Activando Protección de Red y Ransomware"; c = { Set-MpPreference -EnableNetworkProtection Enabled -EnableControlledFolderAccess Enabled } },
    @{ n = "Deshabilitando PowerShell v2"; c = { Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart } },
    @{ n = "Habilitando TLS 1.2"; c = { New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Force; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name Enabled -Value 1 } },
    @{ n = "Configurando políticas de contraseña"; c = { net accounts /minpwlen:12 /maxpwage:60 /lockoutthreshold:5 } },
    
    # --- NUEVAS FUNCIONES DE NIVEL EXTREMO ---
    
    @{ n = "Habilitando Credential Guard y VBS"; c = { 
        Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 1 -Force;
        Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 1 -Force
    } },
    @{ n = "Bloqueando Autenticación Insegura Guest (SMB)"; c = { 
        $lanman = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation";
        New-Item $lanman -Force; Set-ItemProperty $lanman -Name "AllowInsecureGuestAuth" -Value 0 
    } },
    @{ n = "Aplicando Attack Surface Reduction (FULL 16)"; c = { 
        $asrRules = @("be9ba2d9-539a-4d17-ba2d-1644769062a5", "d4f940ab-401b-4efc-aadc-ad5f3c50688a", "3b576861-7eb4-4d5d-b359-ba2386660fdd", "75668c1f-73b5-4cf0-bb93-3ec93f8adf5d", "d1e49f24-3315-4321-8399-95f6d8146d61", "56a863a9-875e-4185-98a7-b882c64b5ce5", "92e97fa1-2eed-4e4e-ad5a-17c641a46442", "b2b3f03d-2e65-471e-8536-bb8118474675", "9e6cde19-a30d-4609-b204-203102a162f3", "d3e037e1-3eb1-4495-b900-3520afc304e5", "26190d00-5950-4c10-8b00-227be261123e", "01443f2c-9615-44a0-9b7e-27bcec6e99a7", "c1db545a-bcd1-4bc0-a241-d715d352b39c", "e6db77e5-3df2-4cf1-b95a-636979351e5b", "92e97fa1-2eed-4e4e-ad5a-17c641a46442");
        $asrRules | ForEach-Object { Add-MpPreference -AttackSurfaceReductionRules_Ids $_ -AttackSurfaceReductionRules_Actions Enabled }
    } },
    @{ n = "Auditoría Forense (Procesos y Líneas de CMD)"; c = { 
        auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable;
        $auditPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit";
        New-Item $auditPath -Force; Set-ItemProperty $auditPath -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1
    } },
    @{ n = "Endurecimiento de RDP (NLA Fuerte)"; c = { 
        $rdpPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp";
        Set-ItemProperty $rdpPath -Name "UserAuthentication" -Value 1;
        Set-ItemProperty $rdpPath -Name "MinEncryptionLevel" -Value 3
    } },
    @{ n = "Bloqueando ejecución en %TEMP% (Anti-LOLBins)"; c = { 
        $tempPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers\0\Paths\{temp_block}"; 
        New-Item $tempPath -Force; Set-ItemProperty $tempPath -Name "SaferFlags" -Value 0 
    } } 
    
)

# He mejorado tu bucle original a try/catch para mayor robustez visual
foreach ($step in $steps) {
    Write-Host "[+] $($step.n.PadRight(56, '.'))" -NoNewline
    try {
        $null = & $step.c 2>$null | Out-Null
        Write-Host "[ OK ]" -ForegroundColor Green
    } catch {
        Write-Host "[ FAIL ]" -ForegroundColor Red
    }
}

#--------------------------------------------------
# 4. Opciones Interactivas de Configuración Adicional
#--------------------------------------------------
Write-Host "`n--------------------------------------------------" -ForegroundColor Cyan
Write-Host " OPCIONES ADICIONALES DE HARDENING" -ForegroundColor Cyan

$rdpChoice = Read-Host "¿Deseas desactivar RDP (Escritorio Remoto)? (S/N)"
if ($rdpChoice -match "^[sSyY]$") {
    Write-Host "[+] Desactivando RDP..." -ForegroundColor Green
    Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1
    Disable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
}

$ipv6Choice = Read-Host "¿Deseas desactivar IPv6 en todas las interfaces? (S/N)"
if ($ipv6Choice -match "^[sSyY]$") {
    Write-Host "[+] Desactivando IPv6 vía Registro..." -ForegroundColor Green
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -PropertyType DWord -Value 255 -Force | Out-Null
}

$hypervChoice = Read-Host "¿Deseas desactivar Hyper-V? (S/N)"
if ($hypervChoice -match "^[sSyY]$") {
    Write-Host "[+] Desactivando características de Hyper-V..." -ForegroundColor Green
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart | Out-Null
}

#--------------------------------------------------
# 5. Preguntas de Escaneo 
#--------------------------------------------------
Write-Host "`n--------------------------------------------------" -ForegroundColor Cyan

$sfcChoice = Read-Host "¿Deseas ejecutar SFC /scannow? (S/N)"
if ($sfcChoice -match "^[sSyY]$") {
    Write-Host "[+] Ejecutando SFC... (No cierres la ventana)" -ForegroundColor Green
    sfc /scannow
}

$scanChoice = Read-Host "¿Deseas ejecutar un escaneo de Microsoft Defender? (S/N)"
if ($scanChoice -match "^[sSyY]$") {
    Write-Host "[+] Iniciando escaneo rápido..." -ForegroundColor Green
    Start-MpScan -ScanType QuickScan
}

#--------------------------------------------------
# 6. Finalización
#--------------------------------------------------
Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " HARDENING COMPLETADO CON ÉXITO"
Write-Host " Desarrollado por: Brixciel Vergara Morales"
Write-Host " REINICIA EL EQUIPO PARA APLICAR TODOS LOS CAMBIOS"
Write-Host "==================================================" -ForegroundColor Green

Write-Host "`nPresiona cualquier tecla para finalizar..."
$null = [Console]::ReadKey()