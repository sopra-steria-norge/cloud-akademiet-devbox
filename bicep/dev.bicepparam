using './main.bicep'

param baseName = 'd-cloudaka-24'
param location = 'westeurope'
param enableNetworking = false
param projectDisplayName = 'Cloud Akademiet 24 - Dev'

param devboxDefinitions = [
  {
    name: 'win11-ent-vs2022'
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
    definition: 'win11-ent-vs2022'
    singleSignOn: 'Enabled'
  }
]

param principalId = '2d267877-042e-4d46-91cc-e45bcb2f1894' // myself (mats)
param principalType = 'User'

