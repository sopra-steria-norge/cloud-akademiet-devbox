# Cloud-akademiet Dev Box

This repository contains the necessary configuration to create [Microsoft Dev Boxes](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box) to use as developer workstations for workshop participants in Cloud-akademiet.

## Admin Usage

## Prerequisities

- [PowerShell 7.x](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
  - [Azure PowerShell module (minimum 12.3)](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell)
- [Bicep tools](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- Owner permissions on a subscription with the Microsoft.DevCenter provider registered

### Deployment

1. Configure parameters in [main.bicepparam](./bicep/main.bicepparam) and save the file
2. Sign into the tenant by running `Connect-AzAccount -Tenant <tenant-id>` in PowerShell
3. Run the deployment with:

```powershell
New-AzDeployment -Name "devbox-$(get-date -Format 'ddMMyy-HHmmss')" -Location 'westeurope' -TemplateFile './bicep/main.bicep' -TemplateParameterFile './bicep/main.bicepparam'
```

### About the Dev Box VMs

The Dev Box definitions are set up as specified in [main.bicepparam](./bicep/main.bicepparam) with:
- Windows 11 with Visual Studio 2022 image
- 8 vCPU, 32 GB RAM, 256 GB SSD storage
- Single-sign on enabled
- Hibernate support with automatic hibernation after 60m of inactivity

The VMs have by default [this list](https://github.com/Azure/dev-box-images?tab=readme-ov-file#preinstalled-software) of available software preinstalled.

Additional customizations are added to the Dev Box by applying the [customization file](./customizations/cloudakademiet.yaml) upon provisioning.

## End User Usage

### Create a new Dev Box

1. Sign into the Developer Portal: https://devportal.microsoft.com/
2. Press **+ New** and select **New Dev Box**
3. Give the Dev Box a name, e.g. `devbox-<firstname>`
4. Select **Apply customizations** and then press **Continue**
5. Upload customization file
    1. Download [this file](https://github.com/sopra-steria-norge/cloud-akademiet-devbox/blob/main/customizations/cloudakademiet.yaml) to a local yaml file on your computer
    2. Select the file for upload and press **Validate**
6. Select **Create** to begin provisioning your Dev Box

For additional guide, see [the official docs](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box#create-a-dev-box).

### Use your Dev Box

1. Sign into the Developer Portal: https://devportal.microsoft.com/
2. Press **Open in RDP Client** on the Dev Box
3. If you do not have the Remote Desktop App, press the link to download and install this app
4. Press **Connect** to connect to your Dev Box

For additional guide, see [the official docs](https://learn.microsoft.com/en-us/azure/dev-box/quickstart-create-dev-box#connect-to-a-dev-box)

**Note**: After initial login you need to update WSL and install Docker Desktop. See [this script](./customizations/winget.ps1) for the commands to isntall these.

### Tips and tricks

- **Restart machine**: In case of required restarts after installations or updates you can restart via Windows menu after connecting, wait a few minutes and then connect again.
- **Install missing software**: Use `winget` to install software. See list of required packages in [this script](./customizations/winget.ps1). You can search all available software for Winget [here](https://winstall.app/).
- **Hibernation**: The machine is set to hibernate after 60m of inactivity. This is to ensure cost efficiency and not to pay for the machine while it is not in use.
- **Visual Studio versions**: The machine already have Visual Studio Enteprise 2022 installed. If you do not have an enterprise license and want to use the community version this will show as "Visual Studio 2022 (2)" in the applications overview.

## Contributing

Feel free to contribute to this repo. Contact @matsest if you have any questions.

## Learn more

- [Microsoft Dev Box Documentation](https://learn.microsoft.com/en-us/azure/dev-box/)
- [Dev Box Key Concepts](https://learn.microsoft.com/en-us/azure/dev-box/concept-dev-box-concepts)
- [Dev Box Customization](https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-dev-box-setup-tasks)