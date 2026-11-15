$ErrorActionPreference = 'Stop'

Uninstall-BinFile -Name 'megacubo'

$shortcut = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Megacubo.lnk"
if (Test-Path $shortcut) {
    Remove-Item $shortcut -Force
}
