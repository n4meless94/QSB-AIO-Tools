# Run locally or with: irm https://github.com/n4meless94/QSB-AIO-Tools/releases/latest/download/launch.ps1 | iex
& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    $previousTls = [Net.ServicePointManager]::SecurityProtocol
    $zipPath = $null
    try {
        if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem) {
            throw 'QSB AIO Tools requires 64-bit Windows.'
        }
        $runtimePresent = $false
        foreach ($key in @(
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}',
            'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}',
            'HKCU:\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
        )) {
            $value = Get-ItemProperty -LiteralPath $key -Name pv -ErrorAction SilentlyContinue
            $version = $null
            if ($value -and [version]::TryParse([string]$value.pv, [ref]$version) -and $version -gt [version]'0.0.0.0') {
                $runtimePresent = $true
                break
            }
        }
        if (-not $runtimePresent) {
            throw 'Install Microsoft Edge WebView2 Evergreen Runtime from https://developer.microsoft.com/microsoft-edge/webview2/ and run this command again.'
        }
        [Net.ServicePointManager]::SecurityProtocol = $previousTls -bor [Net.SecurityProtocolType]::Tls12
        $repository = 'n4meless94/QSB-AIO-Tools'
        Write-Host 'Checking the latest QSB AIO Tools release...'
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repository/releases/latest" -Headers @{
            Accept = 'application/vnd.github+json'
            'User-Agent' = 'QSB-AIO-Tools-launcher'
        } -TimeoutSec 30
        $tag = [string]$release.tag_name
        if ($tag -cnotmatch '^v[0-9]+\.[0-9]+\.[0-9]+(?:[.-][A-Za-z0-9.-]+)?$') {
            throw 'The latest release has an invalid version. Download it from the GitHub release page or contact IT.'
        }
        $assets = @($release.assets | Where-Object { $_.name -ceq 'QSB-AIO-Tools.zip' })
        if ($assets.Count -ne 1 -or [string]$assets[0].digest -notmatch '^sha256:([a-fA-F0-9]{64})$') {
            throw 'The release ZIP or its SHA-256 checksum is unavailable. Contact IT.'
        }
        $expectedHash = $Matches[1]
        $zipPath = Join-Path ([IO.Path]::GetTempPath()) ('QSB-AIO-Tools-' + [guid]::NewGuid().ToString('N') + '.zip')
        Write-Host "Downloading QSB AIO Tools $tag..."
        Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$repository/releases/download/$tag/QSB-AIO-Tools.zip" -OutFile $zipPath -TimeoutSec 120
        if ((Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash -ne $expectedHash) {
            throw 'The download checksum does not match. Nothing was opened. Run the command again.'
        }
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = [IO.Compression.ZipFile]::OpenRead($zipPath)
        try {
            $allowed = @('QSB AIO Tools/QSB AIO Tools.exe', 'QSB AIO Tools/README.md')
            if ($archive.Entries.Count -ne 2 -or @($archive.Entries.FullName | Select-Object -Unique).Count -ne 2 -or @($archive.Entries | Where-Object { $allowed -cnotcontains $_.FullName }).Count) {
                throw 'The release ZIP contains unexpected files. Nothing was opened. Contact IT.'
            }
        } finally {
            $archive.Dispose()
        }
        # ponytail: retain version folders; add cleanup only if disk usage becomes a problem.
        $destination = Join-Path $env:LOCALAPPDATA "QSB-AIO-Tools\releases\$tag"
        try {
            Expand-Archive -LiteralPath $zipPath -DestinationPath $destination -Force
        } catch {
            throw 'Could not save the app files. Close QSB AIO Tools, check that your profile folder is writable, and try again.'
        }
        $executable = Join-Path $destination 'QSB AIO Tools\QSB AIO Tools.exe'
        Write-Host "Opening QSB AIO Tools $tag. BitLocker recovery-key backup is disabled in this public build."
        Start-Process -FilePath $executable -WorkingDirectory (Split-Path -Parent $executable)
    } finally {
        [Net.ServicePointManager]::SecurityProtocol = $previousTls
        if ($zipPath -and (Test-Path -LiteralPath $zipPath)) {
            Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
        }
    }
}
