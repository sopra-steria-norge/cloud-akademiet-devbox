using './main.bicep'

param baseName = 'cloudakademiet24'
param location = 'westeurope'
param enableNetworking = false
param projectDisplayName = 'Cloud Akademiet 24'

param devboxDefinitions = [
  {
    name: 'win11-ent-vs2022-pro'
    image: 'win11-ent-vs2022-pro'
    compute: '8c-32gb'
    storage: '256gb'
    hibernateSupport: true
  }
]
param devboxPools = [
  {
    name: 'cloudakademiet24-devbox-pool'
    administrator: 'Enabled'
    definition: 'win11-ent-vs2022-pro'
    singleSignOn: 'Enabled'
  }
]

param devboxAdmins = [
  {
   principalId: '7b48d9c1-9d69-4f6d-96f8-4e96c000445d'
   principalType: 'Group'
   description:  'cloud-akademiet-admins'
  }
]

param devboxUsers = [
  {
    principalId:  '0c821cd4-4b24-4987-9bb9-420aaf747ec1'
    principalType: 'Group'
    description: 'cloud-akademiet-all'
  }
]


