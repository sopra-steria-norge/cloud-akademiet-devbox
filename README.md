# Cloud-akademiet Dev Box

This repository contains the necessary configuration to create [Microsoft Dev Boxes](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box) to use as developer workstations for workshop participants in Cloud-akademiet.

:point_right: If you are an end user jump directly down to [end user usage](#end-user-usage).

## Admin Usage

This section is inteded for those who are deploying and managing Dev Center, Dev Box definitions and Dev Box pools.

## Prerequisities

- [PowerShell 7.x (tested with 7.5.1)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
  - [Azure PowerShell module (tested with Az 14.0)](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell)
- [Bicep tools (tested with Bicep 0.35.1)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- Owner role assignment on an Azure subscription with the `Microsoft.DevCenter` provider registered
    - [How to: Register Resource Provider Microsoft.DevCenter](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider)
    - [How to: Assign Roles in the Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
    - Note that the quota for DevBoxes General vCPUs in your region might need an increase if you are planning on deploying many. Follow [this guide](https://learn.microsoft.com/en-us/azure/quotas/quickstart-increase-quota-portal) to request a increase if needed.

### Deployment

1. Configure parameters in [main.bicepparam](./bicep/main.bicepparam) and save the file
2. Sign into the tenant by running `Connect-AzAccount -Tenant <tenant-id>` in PowerShell and ensure you select the appropriate subscription for deployment.
  1. Choose the desired subscription with `Set-AzContext -Subscription <subscription name or id>`
3. Run the deployment with:

```powershell
New-AzDeployment -Name "devbox-$(get-date -Format 'ddMMyy-HHmmss')" -Location 'westeurope' -TemplateFile './bicep/main.bicep' -TemplateParameterFile './bicep/main.bicepparam'
```

Note: You can optionally replace Azure PowerShell with Azure CLI to deploy using [`az login`](https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest#sign-into-the-azure-cli) and [`az deployment sub create`](https://learn.microsoft.com/en-us/cli/azure/deployment/sub?view=azure-cli-latest#az-deployment-sub-create).

### About the Dev Box VMs

The Dev Box definitions are set up as specified in [main.bicepparam](./bicep/main.bicepparam) with:
- Windows 11 24H2 with Visual Studio 2022 Enterprise image
- 8 vCPU, 32 GB RAM, 256 GB SSD storage
- Single-sign on enabled
- Hibernate support with automatic hibernation after 60m of inactivity
- Users are given local administrator

The VMs have by default [this list](https://github.com/Azure/dev-box-images?tab=readme-ov-file#preinstalled-software) of available software preinstalled.

Additionally they have a set of customizations defined in [this file](./imagedefinition/imagedefinition.yaml).

### Pricing

For the given size the [pricing per DevBox](https://azure.microsoft.com/en-us/pricing/details/dev-box/) is approximately:

| SKU	| Max Monthly Price	| Hourly Compute	| Monthly Storage |
|-----|-------------------|-----------------|-----------------|
| 8 vCPU, 32 GB RAM, 256 GB Storage	| kr1,564.31 | kr16.87 |	kr215.07 |

Note that *when a Dev Box's total cost (including its monthly storage and hourly compute) reaches the level of the max monthly price of that instance for that month, billing will automatically stop for that Dev Box instance.*

As a cost-saving measurement a [forced hibernation is run on a schedule](./.github/workflows/devbox-hibernator.yml).

## End User Usage

This section is inteded for those who are provided access to provision their own Dev Boxes for development.

### Create a new Dev Box

1. Sign into the Developer Portal: https://devportal.microsoft.com/
2. Press **+ New** and select **New Dev Box**
3. Give the Dev Box a name, e.g. `devbox-<firstname>`
4. Select **Apply customizations** and then press **Continue**
5. Select **Create** to begin provisioning your Dev Box (can take 30-45 minutes)

For additional guide, see [the official docs](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box#create-a-dev-box).

### Use your Dev Box

1. Sign into the Developer Portal: https://devportal.microsoft.com/
2. Press **Open in RDP Client** on the Dev Box
3. Choose **Connect via Windows App**
  - If you do not have the Windows App, press the link to download and install this app
    - [MacOS Download](https://apps.apple.com/us/app/windows-app/id1295203466?mt=12)
    - [Windows Download](https://apps.microsoft.com/detail/9n1f85v9t8bn?hl=nb-NO&gl=NO)
4. Press **Connect** to connect to your Dev Box
5. Enter your Sopra Steria username and password to login

For additional guide, see [the official docs](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box#connect-to-a-dev-box)

### First time configuration

Upon the initial boot there will be some installations that will automatically start:

1. Accept the prompt for installing SQL Server 2022 Express
2. Wait for the installation of SQL Server 2022 Express to complete

You can disregard any Sopra Steria-branded software pop-ups (not needed for this workshop).

### Rancher Desktop Installation

You will for a later part of the workshop need to install [Rancher Desktop](https://rancherdesktop.io). To do this:

1. Open a terminal
2. Run `winget install SUSE.RancherDesktop`
3. Open 'Rancher Desktop' (you don't need to enable Kubernetes) and ensure it runs
4. Open a terminal and run `docker run hello-world`

### Tips and tricks

- **Restart machine**: In case of required restarts after installations or updates you can restart via Windows menu after connecting, wait a few minutes and then connect again. You can also restart the machine via the Developer Portal.
- **Install missing software**: Use `winget` to install software. See list of required packages in [this script](./scripts/winget.ps1). You can search all available software for Winget [here](https://winstall.app/).
- **Update software**: Use `winget upgrade` to upgrade Software. Some examples are listed [here](./scripts/winget.ps1). You can also run Windows Update in settings to trigger system updates.
- **Hibernation**: The machine is set to hibernate after 60m of inactivity. This is to ensure cost efficiency and not to pay for the machine while it is not in use.
- **Visual Studio versions**: The machine already have Visual Studio Professional 2022 installed. If you do not have an license and want to use the community version this will show as "Visual Studio 2022 - Community" in the applications overview.

## Contributing

Feel free to contribute to this repo. Contact @matsest if you have any questions.

## Learn more

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/)
- [Dev Box Key Concepts](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-concepts)
- [Dev Box Customization](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-dev-box-setup-tasks)