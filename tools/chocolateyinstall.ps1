$ErrorActionPreference = 'Stop'

$version = $env:ChocolateyPackageVersion

# The community repository validator requires the checksum and the URL of each download to be
# visible as literals, so each architecture gets its own Install-ChocolateyPackage call instead of
# a hashtable lookup (a looked-up checksum is reported as "downloaded without validating the
# checksum", rule cpmr0073).
if ($version -ne '17.8.0') {
    throw "No literal checksum registered for $version - add a block to tools\chocolateyinstall.ps1 before pushing this version."
}

# A 32-bit PowerShell on a 64-bit host reports x86 in PROCESSOR_ARCHITECTURE and the real
# architecture in PROCESSOR_ARCHITEW6432, which would download the wrong installer.
$arch = $env:PROCESSOR_ARCHITECTURE
if ($env:PROCESSOR_ARCHITEW6432) { $arch = $env:PROCESSOR_ARCHITEW6432 }

$commonArgs = @{
    packageName    = 'megacubo'
    fileType       = 'exe'
    silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /ALLUSERS'
    validExitCodes = @(0)
}

switch ($arch) {
    'ARM64' {
        Install-ChocolateyPackage @commonArgs `
            -url 'https://github.com/EdenwareApps/Megacubo/releases/download/v17.8.0/Megacubo_17.8.0_win_arm64.exe' `
            -checksum '40bb68c6d5da56d06062ec4f2e26eafd6ed5e9b1d1137a3cdd55f95e9015b2f1' `
            -checksumType 'sha256'
    }
    'AMD64' {
        Install-ChocolateyPackage @commonArgs `
            -url 'https://github.com/EdenwareApps/Megacubo/releases/download/v17.8.0/Megacubo_17.8.0_win_x64.exe' `
            -checksum 'bda1e36feb9ce20cd0339f6da51cd8e24ce98e1ccd5508a21da3b5f3d2c36718' `
            -checksumType 'sha256'
    }
    default {
        Install-ChocolateyPackage @commonArgs `
            -url 'https://github.com/EdenwareApps/Megacubo/releases/download/v17.8.0/Megacubo_17.8.0_win_x86.exe' `
            -checksum '097cd2fc9a07100665b27fccfc31bc1539ddafe1a1029b39e9c8dbd8a30eb5ed' `
            -checksumType 'sha256'
    }
}

# The setup is a 32-bit Inno Setup binary, so an all-users install lands in Program Files (x86);
# a per-user install (PrivilegesRequired=lowest without elevation) lands in LOCALAPPDATA.
$roots = @(
    (Join-Path $env:ProgramFiles 'Megacubo'),
    (Join-Path ${env:ProgramFiles(x86)} 'Megacubo'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Megacubo')
)

$exe = $null
foreach ($root in $roots) {
    if (-not $root) { continue }
    $candidate = Join-Path $root 'megacubo.exe'
    if (Test-Path $candidate) { $exe = $candidate; break }
}

if ($exe) {
    Install-BinFile -Name 'megacubo' -Path $exe
}