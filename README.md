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
  `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /ALLUSERS`, so the application lands in
  `C:\Program Files\Megacubo`. Elevation comes from that switch alone: the installer's default mode is
  per-user (`PrivilegesRequired=lowest`), with no UAC prompt.
- The installer registers the `mega://` protocol plus Start Menu and desktop shortcuts.
- `Install-BinFile` adds the `megacubo` shim. Chocolatey's auto uninstaller runs the Inno uninstaller on
  removal and `chocolateyuninstall.ps1` removes the shim.

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
3. Add the three new `"<version>-<arch>"` entries to `$checksums` in `tools\chocolateyinstall.ps1`.
4. `choco pack` and push.

The install script **fails closed**: if the running version has no registered checksum, it throws instead of
installing an unverified download.

## Verified (17.8.0)

- The three Setup installers were rebuilt, signed with the EDENWARE code-signing certificate
  (Authenticode status `Valid`) and uploaded to the GitHub release; the hashes above match the published
  files.
- The silent path used by Chocolatey was exercised by running the x86 Setup directly with `/SILENT
  /SUPPRESSMSGBOXES /NORESTART`: exit code 0, 1624 files installed, zero `lum_sdk*`/`net_updater*`, no
  `megacubo-debug.cmd`, ARP entry `{D95E0592-5CD5-4D5F-A382-3A00BC2F6196}_is1`, `Software\Classes\mega`
  registered, and `/VERYSILENT` uninstall removed the directory, shortcuts and protocol key.
- `choco pack` succeeds and the nuspec validates.
- The elevated `/ALLUSERS` run (what Chocolatey does) was not executed here because it needs UAC; it is the
  documented Inno switch for `PrivilegesRequiredOverridesAllowed=commandline`.