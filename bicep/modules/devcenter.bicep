// MARK: Params
@description('The name of Dev Center e.g. dc-devbox-test')
param devcenterName string

@description('The name of Network Connection e.g. con-devbox-test')
param networkConnectionName string = ''

@description('The name of Dev Center project e.g. dcprj-devbox-test')
param projectName string

@description('The name of Dev Center project as it will be displayed in the UI')
param projectDisplayName string = projectName

@description('The resource group name of Network Connection e.g. rg-devbox-test')
param networkingResourceGroupName string = ''

@description('Flag to enable networking for the dev box')
param enableNetworking bool = false

@description('The resource id of Virtual network subnet')
param subnetId string = ''

@description('Primary location for all resources e.g. eastus')
param location string = resourceGroup().location

@description('List of devbox definitions')
param devboxDefinitions devboxDefinitionType[] = []

@description('List of devbox pools')
param devboxPools devboxPoolType[] = []

@description('The users or groups that will be granted to Devcenter Project Admin role')
param devboxAdmins array = []

@description('The users or groups that will be granted to Devcenter Dev Box User role')
param devboxUsers array = []

@description('The maximum number of dev boxes per user')
param maxDevBoxesPerUser int = 2

// MARK: Variables
var devBoxUserRoleId = '45d50f46-0b78-4001-a660-4198cbe8cd05'
var devCenterAdminRoleId = '331c37c6-af14-46d9-b9f4-e1909e1b95a0'

var image = {
  'win11-ent-base': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
  'win11-ent-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
  'win11-ent-vs2022-ent': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
  'win11-ent-vs2022-pro': 'microsoftvisualstudio_visualstudioplustools_vs-2022-pro-general-win11-m365-gen2'
}

var compute = {
  '8c-32gb': 'general_i_8c32gb256ssd_v2'
  '16c-64gb': 'general_i_16c64gb512ssd_v2'
  '32c-128gb': 'general_i_32c128gb1024ssd_v2'
}

// MARK: Types
@export()
type devboxDefinitionType = {
  name: string
  image: 'win11-ent-base' | 'win11-ent-m365' | 'win11-ent-vs2022-ent'  | 'win11-ent-vs2022-pro'
  compute: '8c-32gb' | '16c-64gb' | '32c-128gb'
  storage: '256gb' | '512gb' | '1024gb' | '2048gb'
  hibernateSupport: bool
}

@export()
type devboxPoolType = {
  name: string
  definition: string
  administrator: 'Enabled' | 'Disabled'
  singleSignOn: 'Enabled' | 'Disabled'
}

@export()
type devboxRoleType = {
  principalId: string
  principalType:  'Group' | 'ServicePrincipal' | 'User'
  description: string
}

// MARK: Resources
resource devcenter 'Microsoft.DevCenter/devcenters@2024-07-01-preview' = {
  name: devcenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

module devcenterRoleAssignment 'roleAssignment.bicep' = {
  scope: subscription()
  name: '${deployment().name}-roleAssignment'
  params: {
    principalId: devcenter.identity.principalId
  }
}

resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2024-07-01-preview' = {
  name: 'default'
  parent: devcenter
  properties: {
    gitHub: {
      uri: 'https://github.com/microsoft/devcenter-catalog.git'
      branch: 'main'
      path: 'Tasks'
    }
    syncType: 'Scheduled'
  }
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-07-01-preview' = if(enableNetworking) {
  name: networkConnectionName
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: networkingResourceGroupName
  }
}

resource attachedNetworks 'Microsoft.DevCenter/devcenters/attachednetworks@2024-07-01-preview' = if(enableNetworking) {
  parent: devcenter
  name: networkConnection.name
  properties: {
    networkConnectionId: networkConnection.id
  }
}

resource devboxDefinitionsRes 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-07-01-preview' = [for definition in devboxDefinitions: {
  parent: devcenter
  name: definition.name
  location: location
  properties: {
    hibernateSupport: 'Enabled'
    imageReference: {
      id: '${devcenter.id}/galleries/default/images/${image[definition.image]}'
    }
    sku: {
      name: compute[definition.compute]
    }
    osStorageType: 'ssd_${definition.storage}'
  }
  dependsOn: [
    attachedNetworks
  ]
}]

resource project 'Microsoft.DevCenter/projects@2024-07-01-preview' = {
  name: projectName
  location: location
  properties: {
    devCenterId: devcenter.id
    displayName: projectDisplayName
    maxDevBoxesPerUser: maxDevBoxesPerUser
  }
  resource pools 'pools' = [for pool in devboxPools: {
    name: pool.name
    location: location
    properties: {
      devBoxDefinitionName: pool.definition
      displayName: pool.name
      networkConnectionName: enableNetworking ? networkConnection.name : 'managedNetwork'
      virtualNetworkType: enableNetworking ? 'Unmanaged' : 'Managed'
      devBoxDefinitionType: 'Reference'
      managedVirtualNetworkRegions: enableNetworking ? [] : [location]
      licenseType: 'Windows_Client'
      localAdministrator: pool.administrator
      singleSignOnStatus: pool.singleSignOn
      stopOnDisconnect: {
        gracePeriodMinutes: 60
        status: 'Enabled'
      }
    }
  }]
  dependsOn: [
    devcenterRoleAssignment
    devboxDefinitionsRes
  ]
}

// Role assignment for dev box users
resource devboxUsersRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in devboxUsers: {
  name: guid(subscription().id, resourceGroup().id, item.principalId, devBoxUserRoleId)
  scope: project
  properties: {
    principalId: item.principalId
    principalType: item.principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', devBoxUserRoleId)
  }
}]

// Role assignment for dev box users
resource devcenterAdminsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in devboxAdmins: {
  name: guid(subscription().id, resourceGroup().id, item.principalId, devCenterAdminRoleId)
  scope: project
  properties: {
    principalId: item.principalId
    principalType: item.principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', devCenterAdminRoleId)
  }
}]

// MARK: Outputs
output devcenterName string = devcenter.name

output definitions array = [for (definition, i) in devboxDefinitions: {
  name: devboxDefinitions[i].name
}]

output networkConnectionName string = enableNetworking ? networkConnection.name : ''

output projectName string = project.name

output poolNames array = [for (pool, i) in devboxPools: {
  name: project::pools[i].name
}]
