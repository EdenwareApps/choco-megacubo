$ErrorActionPreference = 'Stop'

# The application itself is removed by Chocolatey's auto uninstaller, which runs
# the Inno Setup uninstaller silently.
Uninstall-BinFile -Name 'megacubo'