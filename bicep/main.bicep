targetScope = 'subscription'

import {devboxDefinitionType, devboxPoolType, devboxRoleType} from './modules/devcenter.bicep'

// MARK: Params
@maxLength(16)
@description('The name to use as a base for other names')
param baseName string

@description('Primary location for all resources')
param location string 

@description('The name of the resource group')
param resourceGroupName string = '${baseName}-rg'

@description('The name of Dev Center')
param devcenterName string = '${baseName}-${take(uniqueString(subscription().id, resourceGroupName), 3)}-dc'

@description('Flag to enable networking for the dev box')
param enableNetworking bool = false

@description('List of devbox definitions')
param devboxDefinitions devboxDefinitionType[] = []

@description('List of devbox pools')
param devboxPools devboxPoolType[] = []

@description('The name of Network Connection')
param networkConnectionName string = '${baseName}-con'

@description('The name of Dev Center project')
param projectName string = '${baseName}-dcprj'

@description('The name of Dev Center project as it will be displayed in the UI')
param projectDisplayName string = projectName

@description('The name of the Virtual Network e.g. vnet-dcprj-devbox-test-eastus')
param vnetName string = '${projectName}-${location}-vnet'

@description('the subnet name of Dev Box e.g. default')
param subnetName string = 'default'

@description('The vnet address prefixes of Dev Box e.g. 10.4.0.0/16')
param vnetAddressPrefixes string = '10.4.0.0/16'

@description('The subnet address prefixes of Dev Box e.g. 10.4.0.0/24')
param subnetAddressPrefixes string = '10.4.0.0/24'

@description('Name of the networking resource group')
param networkingResourceGroupName string = '${resourceGroupName}-network'

@description('The users or groups that will be granted to Devcenter Project Admin role')
param devboxAdmins devboxRoleType[] = []

@description('The users or groups that will be granted to Devcenter Dev Box User role')
param devboxUsers devboxRoleType[] = []

// MARK: Resources
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location:  location
}

// Deploy virtual network if needed
module vnet 'modules/vnet.bicep' = if(enableNetworking) {
  name: '${deployment().name}-vnet'
  scope: rg
  params: {
    location: location
    vnetAddressPrefixes: vnetAddressPrefixes
    vnetName: vnetName
    subnetAddressPrefixes: subnetAddressPrefixes
    subnetName: subnetName
  }
}

// Deploy dev center, dev box definitions and dev box pools
module devcenter 'modules/devcenter.bicep' = {
  name: '${deployment().name}-devcenter'
  scope: rg
  params: {
    location: location
    devcenterName: devcenterName
    enableNetworking: enableNetworking
    devboxDefinitions: devboxDefinitions
    devboxPools: devboxPools
    subnetId: enableNetworking ? vnet.outputs.subnetId : ''
    networkConnectionName: networkConnectionName
    projectName: projectName
    projectDisplayName: projectDisplayName
    networkingResourceGroupName: networkingResourceGroupName
    devboxUsers: devboxUsers
    devboxAdmins: devboxAdmins
  }
}

// MARK: Outputs 
output devcenterName string = devcenter.outputs.devcenterName
output projectName string = devcenter.outputs.projectName
output networkConnectionName string = devcenter.outputs.networkConnectionName
output definitions array = devcenter.outputs.definitions
output pools array = devcenter.outputs.poolNames
