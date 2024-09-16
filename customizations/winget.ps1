# Install developer toolings
winget install "Microsoft.VisualStudio.2022.Community"
winget install "Microsoft.SQLServerManagementStudio"
winget install "Microsoft.SQLServer.2022.Express"
winget install "Microsoft.DotNet.Framework.DeveloperPack_4"

# Install WSL
wsl --install --no-distribution
# Restart computer after this step

# Install Docker Desktop
winget install docker-desktop -y --no-progress
# Restart computer again after this step