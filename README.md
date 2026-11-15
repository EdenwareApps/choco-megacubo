# Megacubo — Chocolatey package

Community package for [Megacubo](https://megacubo.tv), an open-source (GPL-3.0) IPTV player for Windows.

The package does **not** wrap the web downloader (`megacubo.tv/bin/*.exe`, a 3.3 MB NSIS stub that fetches the
payload and bundles the Bright SDK). It installs the official **portable** archive published by the developer,
which contains `megacubo.exe` at its root and no third-party SDK binaries:

- `https://megacubo.tv/bin/portable/Megacubo_<version>_x64.7z`
- `https://megacubo.tv/bin/portable/Megacubo_<version>_x86.7z`
- `https://megacubo.tv/bin/portable/Megacubo_<version>_arm64.7z`

Each archive has a sibling `.sha256` file.

## Build

```powershell
choco pack
```

Produces `megacubo.<version>.nupkg`, which contains only `tools\chocolateyinstall.ps1` and
`tools\chocolateyuninstall.ps1` — the payload is downloaded at install time from the official server.

## Push to the community feed

Requires a Chocolatey community account and an API key (`choco apikey`):

```powershell
choco apikey --key <API_KEY> --source https://push.chocolatey.org/
choco push megacubo.17.8.0.nupkg --source https://push.chocolatey.org/
```

## Bumping the version

1. Publish the new portable archives on the server (see `docs/GSA_AUTO_SOFTSUBMIT_CONTROLE.md`, §10.10.4).
2. Update `version` in `megacubo.nuspec`.
3. Add the three new `"<version>-<arch>"` entries to `$checksums` in `tools\chocolateyinstall.ps1`.
4. `choco pack` and push.

The install script **fails closed**: if the running version has no registered checksum, it throws instead of
installing an unverified download.

## Verified

- `Get-ChocolateyWebFile` + `Get-ChocolateyUnzip` run against `17.8.0_x64`: download 138.78 MB, hash match,
  extraction produces `megacubo.exe` (245 MB) with no `lum_sdk*`/`net_updater*` files.
- `choco pack` succeeds; nuspec validates; both scripts parse without syntax errors.
- Full `choco install` (shim + Start Menu shortcut) needs elevation, so it was not run here; `Install-BinFile`
  was reached and only failed writing to `C:\ProgramData\chocolatey\bin` for lack of administrator rights.
