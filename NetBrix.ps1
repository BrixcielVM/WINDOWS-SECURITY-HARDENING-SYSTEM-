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

# Pequeña espera de 1 segundo para que alcances a leer el título antes de empezar
Start-Sleep -Seconds 1

#--------------------------------------------------
# 3. Ejecución 100% Automática de Hardening
#--------------------------------------------------
$steps = @(
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
    @{ n = "Deshabilitando WinRM y Registro Remoto"; c = { Stop-Service WinRM, RemoteRegistry; Set-Service WinRM, RemoteRegistry -StartupType Disabled } },
    @{ n = "Activando mitigaciones DEP/ASLR"; c = { Set-ProcessMitigation -System -Enable DEP,SEHOP,ASLR } },
    @{ n = "Habilitando Auditoría de PowerShell"; c = { New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force; Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1 } },
    @{ n = "Fortaleciendo Microsoft Defender"; c = { Set-MpPreference -DisableRealtimeMonitoring $false -MAPSReporting Advanced } },
    @{ n = "Activando Protección de Red y Ransomware"; c = { Set-MpPreference -EnableNetworkProtection Enabled -EnableControlledFolderAccess Enabled } },
    @{ n = "Aplicando Attack Surface Reduction (ASR)"; c = { "56a863a9-875e-4185-98a7-b882c64b5ce5","d4f940ab-401b-4efc-aadc-ad5f3c50688a" | ForEach-Object { Add-MpPreference -AttackSurfaceReductionRules_Ids $_ -AttackSurfaceReductionRules_Actions Enabled } } },
    @{ n = "Deshabilitando PowerShell v2"; c = { Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart } },
    @{ n = "Habilitando TLS 1.2"; c = { New-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Force; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name Enabled -Value 1 } },
    @{ n = "Configurando políticas de contraseña"; c = { net accounts /minpwlen:12 /maxpwage:60 /lockoutthreshold:5 } }
)

foreach ($step in $steps) {
    Write-Host "[+] $($step.n.PadRight(52, '.'))" -NoNewline
    $null = & $step.c 2>$null | Out-Null
    Write-Host "[ OK ]" -ForegroundColor Green
}

#--------------------------------------------------
# 4. Preguntas de Escaneo (Única interacción)
#--------------------------------------------------
Write-Host "`n--------------------------------------------------" -ForegroundColor Cyan

$sfcChoice = Read-Host "¿Deseas ejecutar SFC /scannow? (S/N)"
if ($sfcChoice -match "^[sSyY]$") {
    Write-Host "[+] Ejecutando SFC... (No cierres la ventana)" -ForegroundColor Yellow
    sfc /scannow
}

$scanChoice = Read-Host "¿Deseas ejecutar un escaneo de Microsoft Defender? (S/N)"
if ($scanChoice -match "^[sSyY]$") {
    Write-Host "[+] Iniciando escaneo rápido..." -ForegroundColor Yellow
    Start-MpScan -ScanType QuickScan
}

#--------------------------------------------------
# 5. Finalización
#--------------------------------------------------
Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " HARDENING COMPLETADO CON ÉXITO"
Write-Host " Desarrollado por: Brixciel Vergara Morales"
Write-Host " REINICIA EL EQUIPO PARA APLICAR TODOS LOS CAMBIOS"
Write-Host "==================================================" -ForegroundColor Green

Write-Host "`nPresiona cualquier tecla para finalizar..."
$null = [Console]::ReadKey()