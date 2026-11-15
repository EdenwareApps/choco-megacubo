$ErrorActionPreference = 'Stop'

$version = $env:ChocolateyPackageVersion

$architecture = switch ($env:PROCESSOR_ARCHITECTURE) {
    'ARM64' { 'arm64' }
    'AMD64' { 'x64' }
    default { 'x86' }
}

# SHA256 of the official Inno Setup installers published on the GitHub release.
$checksums = @{
    '17.8.0-arm64' = 'a2a3e85eaac20f75c28b85cc8b917043b789be4cdd93123c09c551567f143e1e'
    '17.8.0-x64'   = '0543a27a73bf609580912fad2f61ac7247b3bb6dc1b94589af42eef410939dd0'
    '17.8.0-x86'   = '2c4621c0dc312a5eacfbccec390aa9dd8cd17fa106db7f99709d47cf70ba4b23c'
}

$key = "$version-$architecture"
if (-not $checksums.ContainsKey($key)) {
    throw "No checksum registered for $key - update tools\chocolateyinstall.ps1 before pushing this version."
}

$url = "https://github.com/EdenwareApps/Megacubo/releases/download/v${version}/Megacubo_${version}_win_${architecture}.exe"

$packageArgs = @{
    packageName    = 'megacubo'
    fileType       = 'exe'
    url            = $url
    checksum       = $checksums[$key]
    checksumType   = 'sha256'
    silentArgs     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /ALLUSERS'
    validExitCodes = @(0)
}

Install-ChocolateyPackage @packageArgs

$programFiles = $env:ProgramW6432
if (-not $programFiles) { $programFiles = $env:ProgramFiles }

$exe = Join-Path (Join-Path $programFiles 'Megacubo') 'megacubo.exe'
if (Test-Path $exe) {
    Install-BinFile -Name 'megacubo' -Path $exe
}