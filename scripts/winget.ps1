# Install developer toolings (all of these should be already installed)
winget install "Microsoft.VisualStudio.2022.Community"
winget install "Microsoft.SQLServerManagementStudio"
winget install "Microsoft.SQLServer.2022.Express"
winget install "Microsoft.DotNet.Framework.DeveloperPack_4"

## The following steps need to be done after initial Dev Box login
# 1. Update WSL
# wsl --update
# 2. Restart computer after this step
# 3. Install Rancher Desktop
# winget install --id=SUSE.RancherDesktop
# 4. Restart computer again after this step

# Optional: Update existing software if needed
winget upgrade --id Microsoft.WindowsTerminal
winget upgrade --id Git.Git
winget upgrade --id Microsoft.AzureCLI