# Windows Security Hardening System (.exe)

Este proyecto es una herramienta de seguridad avanzada diseñada para fortalecer la postura de defensa de sistemas Windows 10 y 11. Desarrollado originalmente en **PowerShell** y distribuido como un **ejecutable (.exe)**, el sistema automatiza tareas críticas de hardening que normalmente requerirían horas de configuración manual.

**Autor:**  Brixciel Vergara Morales  

---
## 🛠️ Evolución: De .ps1 a .exe profesional

Para garantizar la integridad y facilitar el despliegue en entornos corporativos o técnicos, el código base ha sido transformado de un script plano a un binario ejecutable.

* **Ejecución "Zero-Touch":** El programa inicia el hardening automáticamente tras validar permisos.
* **Solicitud de Privilegios:** Incluye un manifiesto interno que fuerza la ejecución como Administrador (UAC).
* **Portabilidad:** Supera las restricciones de `ExecutionPolicy` que suelen bloquear archivos `.ps1` en sistemas seguros.
* **Interfaz Limpia:** Salida optimizada que silencia procesos en segundo plano para mostrar solo el progreso real.

---

🔒 Medidas de Seguridad Aplicadas
El sistema ejecuta una matriz de hardening dividida en capas estratégicas:

🌐 Red y Conectividad
Firewall de Windows: Activación forzada en perfiles de Dominio, Privado y Público.

Bloqueo de Puertos: Cierre de puertos vulnerables (21, 23, 69, 135, 137-139, 445).

Protocolos Inseguros: Desactivación de SMBv1, NetBIOS sobre TCP/IP y resolución LLMNR.

Autenticación SMB: Bloqueo de Insecure Guest Auth y requisito de firma digital (SMB Signing).

Cifrado: Forzado de TLS 1.2 para comunicaciones seguras.

🛡️ Protección de Núcleo y Procesos (Nivel Experto)
Virtualization-Based Security (VBS): Habilitación de Credential Guard para aislar secretos del sistema en contenedores virtualizados.

LSASS: Activación de protección de procesos adicionales (PPL) para evitar el robo de credenciales en memoria (Anti-Mimikatz).

Mitigaciones de Exploits: Habilitación robusta de DEP, SEHOP y ASLR (BottomUp y HighEntropy) con sistema de doble verificación (Cmdlet + Registro).

WDigest: Deshabilitado para evitar el almacenamiento de contraseñas en texto plano.

🏠 Políticas y Servicios de Sistema
Anti-LOLBins: Bloqueo de ejecución de binarios del sistema en directorios temporales (%TEMP%) para prevenir el uso de herramientas legítimas con fines maliciosos.

Servicios Críticos: Desactivación de WinRM, Registro Remoto y el servicio Print Spooler (mitigación definitiva contra vulnerabilidades tipo PrintNightmare).

Control de Acceso: Configuración estricta de UAC (User Account Control) y activación de SmartScreen.

Dispositivos Externos: Desactivación de AutoRun en todas las unidades para prevenir infecciones vía USB.

🔍 Auditoría Forense y Visibilidad
Auditoría de Procesos: Configuración avanzada para registrar la línea de comandos exacta de cada proceso creado, permitiendo rastrear la actividad de un atacante.

PowerShell Logging: Activación de Script Block Logging para auditar la ejecución de comandos y scripts, incluso si están ofuscados.

🛡️ Defensa Activa (Microsoft Defender)
ASR (Attack Surface Reduction): Aplicación de las 16 reglas principales para bloquear comportamientos sospechosos de aplicaciones de Office, scripts y correos electrónicos.

Anti-Ransomware: Activación del Acceso Controlado a Carpetas para proteger archivos críticos.

Protección de Red: Filtrado activo contra dominios maliciosos y reputación de archivos.

## 💻 Guía de Uso

1.  Descarga el ejecutable `NetBrix_Final.exe`.
2.  Ejecuta el archivo (el sistema solicitará permisos de administrador).
3.  **Hardening Automático:** El sistema aplicará las medidas sin intervención.
4.  **Mantenimiento Opcional:** Al finalizar, el programa te preguntará si deseas ejecutar:
5.  *` Deseas desactivar RDP (Escritorio Remoto).
6.  *` Deseas desactivar IPv6 en todas las interfaces
7.  *`¿Deseas desactivar Hyper-V?  
8.- *`SFC /scannow` (Reparación de archivos de sistema).
9.- *`Escaneo rápido de Microsoft Defender`.
10.-*Reinicio:** Es fundamental reiniciar el equipo para consolidar los cambios en el registro.


   
