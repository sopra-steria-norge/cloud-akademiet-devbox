using './main.bicep'

param baseName = 'cloudakademiet24'
param location = 'westeurope'
param enableNetworking = false
param projectDisplayName = 'Cloud Akademiet 24'

param devboxDefinitions = [
  {
    name: 'win11-ent-vs2022'
    image: 'win11-ent-vs2022'
    compute: '8c-32gb'
    storage: '256gb'
    hibernateSupport: true
  }
]
param devboxPools = [
  {
    name: 'cloudakademiet24-devbox-pool'
    administrator: 'Enabled'
    definition: 'win11-ent-vs2022'
    singleSignOn: 'Enabled'
  }
]

param principalId = '0c821cd4-4b24-4987-9bb9-420aaf747ec1' // cloud-akademiet-all
param principalType = 'Group'

