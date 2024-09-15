using './main.bicep'

param baseName = 'cloudakademiet24'
param location = 'swedencentral'
param enableNetworking = false

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

param principalId = '73c21db6-81e9-4f00-a5f6-55dc2ec9ad69' // cloud-akademiet-all
param principalType = 'Group'

