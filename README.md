# Windows Security Hardening System (.exe)

Este proyecto es una herramienta de seguridad avanzada diseñada para fortalecer la postura de defensa de sistemas Windows 10 y 11. Desarrollado originalmente en **PowerShell** y distribuido como un **ejecutable (.exe)**, el sistema automatiza tareas críticas de hardening que normalmente requerirían horas de configuración manual.

**Autor:** Brixciel Vergara Morales  
**Perfil:** Ingeniero de Conectividad, Redes y Arquitectura Cloud.

---
## 🛠️ Evolución: De .ps1 a .exe profesional

Para garantizar la integridad y facilitar el despliegue en entornos corporativos o técnicos, el código base ha sido transformado de un script plano a un binario ejecutable.

* **Ejecución "Zero-Touch":** El programa inicia el hardening automáticamente tras validar permisos.
* **Solicitud de Privilegios:** Incluye un manifiesto interno que fuerza la ejecución como Administrador (UAC).
* **Portabilidad:** Supera las restricciones de `ExecutionPolicy` que suelen bloquear archivos `.ps1` en sistemas seguros.
* **Interfaz Limpia:** Salida optimizada que silencia procesos en segundo plano para mostrar solo el progreso real.

---

## 🔒 Medidas de Seguridad Aplicadas 

El sistema ejecuta una matriz de hardening dividida en capas estratégicas:

**### 🌐 Red y Conectividad
* **Firewall de Windows:** Activación forzada en perfiles de Dominio, Privado y Público.
* **Bloqueo de Puertos:** Cierre de puertos vulnerables (`21, 23, 69, 135, 137-139, 445`).
* **Protocolos Inseguros:** Desactivación de **SMBv1**, **NetBIOS** sobre TCP/IP y resolución **LLMNR**.
* **Cifrado:** Forzado de **TLS 1.2** y requisito de firma digital en **SMB (Signing)**.

### 🛡️ Protección de Núcleo y Procesos
* **LSASS:** Activación de protección de procesos adicionales (PPL) para evitar el robo de credenciales en memoria.
* **Mitigaciones de Exploits:** Habilitación de **DEP**, **SEHOP** y **ASLR** a nivel de sistema.
* **WDigest:** Deshabilitado para evitar el almacenamiento de contraseñas en texto plano.

### 🏠 Políticas y Servicios de Sistema
* **Servicios Críticos:** Desactivación de **WinRM** y **Registro Remoto**.
* **Control de Acceso:** Configuración estricta de **UAC** y activación de **SmartScreen**.
* **Dispositivos Externos:** Desactivación de **AutoRun** en todas las unidades para prevenir malware vía USB.

### 🛡️ Defensa Activa (Microsoft Defender)
* **ASR (Attack Surface Reduction):** Aplicación de reglas para bloquear comportamientos sospechosos de Office y scripts.
* **Anti-Ransomware:** Activación del Acceso Controlado a Carpetas.
* **Protección de Red:** Filtrado activo contra dominios maliciosos.**

---

## 💻 Guía de Uso

1.  Descarga el ejecutable `HardeningSystem.exe`.
2.  Ejecuta el archivo (el sistema solicitará permisos de administrador).
3.  **Hardening Automático:** El sistema aplicará las 21 medidas sin intervención.
4.  **Mantenimiento Opcional:** Al finalizar, el programa te preguntará si deseas ejecutar:
    * `SFC /scannow` (Reparación de archivos de sistema).
    * `Escaneo rápido de Microsoft Defender`.
5.  **Reinicio:** Es fundamental reiniciar el equipo para consolidar los cambios en el registro.

---

## 🏗️ Compilación (Development)

Si deseas auditar el código fuente o realizar tu propia build, el script utiliza el siguiente comando de compilación:

```powershell
Invoke-PS2EXE -inputFile ".\HardeningSystem.ps1" -outputFile ".\HardeningSystem.exe" -requireAdmin -title "Windows Security Hardening" -description "By Brixciel Vergara"
