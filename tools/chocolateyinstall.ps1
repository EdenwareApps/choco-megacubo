$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$version = $env:ChocolateyPackageVersion

$architecture = switch ($env:PROCESSOR_ARCHITECTURE) {
    'ARM64' { 'arm64' }
    'AMD64' { 'x64' }
    default { 'x86' }
}

# Checksums of the official portable archives; keep in sync when bumping the version.
$checksums = @{
    '17.8.0-arm64' = 'fc504e55938fdec6828ad6dfdb6f060eedf889c9b37edcbec98eb9d5d457cc39'
    '17.8.0-x64'   = '89ba8fd01c4106a8ee7d14a9ada613307f14e3a07045e02aa180fc9bcce41e88'
    '17.8.0-x86'   = '7cfaf80f8360fdbf5c67cbee22801affe4927eebe80b7952b31ce6468df65477'
}

$key = "$version-$architecture"
if (-not $checksums.ContainsKey($key)) {
    throw "No checksum registered for $key - update tools\chocolateyinstall.ps1 before pushing this version."
}

$url = "https://megacubo.tv/bin/portable/Megacubo_${version}_${architecture}.7z"
$archive = Join-Path $toolsDir 'megacubo.7z'

Get-ChocolateyWebFile -PackageName 'megacubo' -FileFullPath $archive -Url $url `
    -Checksum $checksums[$key] -ChecksumType 'sha256'

Get-ChocolateyUnzip -FileFullPath $archive -Destination $toolsDir -PackageName 'megacubo'
Remove-Item $archive -Force

Install-BinFile -Name 'megacubo' -Path (Join-Path $toolsDir 'megacubo.exe')
Install-ChocolateyShortcut -ShortcutFilePath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Megacubo.lnk" `
    -TargetPath (Join-Path $toolsDir 'megacubo.exe') -WorkingDirectory $toolsDir
