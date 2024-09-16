# Install developer toolings (all of these should be already installed)
winget install "Microsoft.VisualStudio.2022.Community"
winget install "Microsoft.SQLServerManagementStudio"
winget install "Microsoft.SQLServer.2022.Express"
winget install "Microsoft.DotNet.Framework.DeveloperPack_4"

## REQUIRED
## The following steps need to be done after initial Dev Box login
# Update WSL
wsl --update
# Restart computer after this step

# Install Docker Desktop
winget install --id=Docker.DockerDesktop -e
# Restart computer again after this step

# Optional: Update existing software if needed
winget upgrade --id Microsoft.WindowsTerminal
winget upgrade --id Git.Git
winget upgrade --id Microsoft.AzureCLI