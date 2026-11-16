# Megacubo - Chocolatey package

Community package for [Megacubo](https://megacubo.tv), an open-source (GPL-3.0) IPTV player for Windows.

The package installs the official **Inno Setup installer** published on the GitHub release and signed by
EDENWARE. It is not the web downloader (`megacubo.tv/bin/*.exe`, a small stub that fetches the payload and
bundles the Bright SDK): the release Setup ships the whole application offline, with no Bright SDK binaries
(`lum_sdk*`, `net_updater*`) and without the old `megacubo-debug.cmd`.

- `https://github.com/EdenwareApps/Megacubo/releases/download/v<version>/Megacubo_<version>_win_x64.exe`
- `https://github.com/EdenwareApps/Megacubo/releases/download/v<version>/Megacubo_<version>_win_x86.exe`
- `https://github.com/EdenwareApps/Megacubo/releases/download/v<version>/Megacubo_<version>_win_arm64.exe`

## Install behaviour

- `Install-ChocolateyPackage -fileType exe` runs the Setup with
  `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /ALLUSERS`. The Setup is a **32-bit Inno Setup 6.4.x
  build**, so an all-users install lands in `C:\Program Files (x86)\Megacubo` (not `Program Files`).
  `/SUPPRESSMSGBOXES` is required: the installer's `[Code]` section raises a non-fatal
  `Runtime error (at 94:63): Could not call proc.` when there is no interactive session, and without that
  switch the message box would block the install.
- The installer registers the `mega://` protocol plus Start Menu and desktop shortcuts.
- `Install-BinFile` adds the `megacubo` shim, and the script looks for `megacubo.exe` in `Program Files`,
  `Program Files (x86)` and `%LOCALAPPDATA%\Programs` (the per-user fallback). Chocolatey's auto uninstaller
  runs the Inno uninstaller on removal and `chocolateyuninstall.ps1` removes the shim.

## Build

```powershell
choco pack
```

Produces `megacubo.<version>.nupkg`, which contains only the scripts in `tools\` - the payload is downloaded
at install time from the official release.

## Push to the community feed

Requires a Chocolatey community account and an API key (`choco apikey`):

```powershell
choco apikey --key <API_KEY> --source https://push.chocolatey.org/
choco push megacubo.17.8.0.nupkg --source https://push.chocolatey.org/
```

## Bumping the version

1. Publish the new Setup installers on the GitHub release.
2. Update `version` in `megacubo.nuspec`.
3. Replace the three checksum literals in `tools\chocolateyinstall.ps1` (one per architecture, selected by
   a `switch` on `PROCESSOR_ARCHITEW6432`/`PROCESSOR_ARCHITECTURE`).
4. `choco pack` and push.

The install script **fails closed**: if the package version is not the one the literals were written for, it
throws instead of installing an unverified download.

## Checksums

The checksums are literals inline in `tools\chocolateyinstall.ps1` - the v6 validation rule (cpmr0073)
requires the URL and the checksum to be passed as literals, not looked up in a table. They must match the
assets served by GitHub **at install time**: the v17.8.0 Windows assets were re-uploaded after the release
was published, which silently invalidated the first set of hashes and made the install verification fail.
Read them from the API instead of hashing a local copy:

```powershell
gh api repos/EdenwareApps/Megacubo/releases/tags/v17.8.0 `
  --jq '.assets[] | select(.name|endswith(".exe")) | "\(.name) \(.digest)"'
```

## Verified (17.8.0)

- The silent path used by the package was exercised directly with
  `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /ALLUSERS`: exit code `0` in 43.5 s, install directory
  `C:\Program Files (x86)\Megacubo`, no hung process, no Bright SDK binaries (`lum_sdk*`, `net_updater*`)
  and no `megacubo-debug.cmd`.
- `unins000.exe` is present, so the Chocolatey auto uninstaller works.
- The three checksums were re-read from the release `digest` fields after the assets were re-uploaded.
- `choco pack` succeeds and the nuspec validates.
