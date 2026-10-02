# QSB AIO Tools

Portable Windows tools for local diagnostics and repairs. This repository provides public downloads; the application source is maintained separately.

## Download and open

Open PowerShell and run:

```powershell
irm 'https://github.com/n4meless94/QSB-AIO-Tools/releases/latest/download/launch.ps1' | iex
```

The command executes the published launcher. You can [read it](https://github.com/n4meless94/QSB-AIO-Tools/blob/main/launch.ps1) before running it. It checks WebView2, downloads the latest ZIP, verifies its SHA-256 digest from GitHub, extracts it under your local application data, and opens the app. It does not request administrator access or start a repair. Windows asks for administrator access when you choose a repair that requires it.

You can also [download the ZIP](https://github.com/n4meless94/QSB-AIO-Tools/releases/latest/download/QSB-AIO-Tools.zip), extract it, and open `QSB AIO Tools.exe` yourself.

## Requirements

- 64-bit Windows with Windows PowerShell 5.1 or PowerShell 7 for the launcher.
- [Microsoft Edge WebView2 Evergreen Runtime](https://developer.microsoft.com/microsoft-edge/webview2/). If missing, install it and run the command again.

## Tools

- System Information and Event Log Export
- Disk Cleanup
- Network Reset and offline Wi-Fi troubleshooting guides
- SFC / DISM System Repair
- Windows Update Repair
- BitLocker status and work-account checks

**BitLocker recovery-key backup is disabled in this public build.** Internal pilot identifiers are omitted. This build does not upload recovery keys.

Repairs explain their impact before starting. Windows Update policy removal requires a separate choice. Reports, activity, and settings stay in your Windows profile; the app does not email or upload reports. Review diagnostic reports before sharing them.

The launcher needs internet access to obtain the current release. Existing downloaded copies can be opened directly when offline. Earlier version folders remain under `%LOCALAPPDATA%\QSB-AIO-Tools\releases`; app reports and settings are stored separately.

## If the command stops

Install WebView2 if requested. For download or checksum failures, check your connection and run the command again. If files cannot be saved, close QSB AIO Tools and check that your profile folder is writable. Ask IT if organisational PowerShell policies, application controls, or Windows security checks block the app.
