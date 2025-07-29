@description('作成するシステム名を指定します。')
param systemName string = 'diary'

@description('リソースグループのロケーション。今回は東日本リージョン (Japan East) を指定します。')
param location string = 'japaneast'

@description('環境を指定します。dev, stg, pro のいずれかを選択してください。')
@allowed([
  'dev'
  'stg'
  'pro'
])
param env string = 'dev'

@description('仮想ネットワークのアドレスプレフィックス（例: 10.0.0.0/16）')
param addressPrefixes array = [
  '10.0.0.0/16'
]

@description('可用性ゾーンを設定します。Zone numbers e.g. 1,2,3.')
param availabilityZones array = []

@description('仮想マシンのサイズを指定します。')
@allowed([
  'Standard_B1s'
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_F1'
  'Standard_B2ms'
])
param vmSize string = 'Standard_B2s'

@description('マネージドディスクの種類を指定します。')
@allowed([
  'PremiumV2_LRS'
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('仮想マシンのログインユーザー名を指定します。' )
param adminUsername string = 'azureuser'

@description('仮想マシンのログインパスワードを指定します。' )
@minLength(12)
@secure()
param adminPassword string // P@ssw0rd1234!

@description('ネットワークセキュリティグループの名前。')
var nsgName = 'nsg-${systemName}-${env}'

@description('仮想ネットワークの名前。')
var vnetName = 'vnet-${systemName}-${env}'

@description('作成するサブネットの一覧。各サブネットに名前とアドレスプレフィックスを指定します。')
var subnets = [
  {
    name: 'snet-worker'
    subnetPrefix: '10.0.1.0/24'
  }
]

@description('仮想マシンのパブリックIPアドレスの名前。')
var pipVMName = 'pip-${systemName}-${env}-vm'

@description('ネットワークインターフェイスの名前。')
var nicName = 'nic-${systemName}-${env}'

@description('仮想マシンの名前。')
var vmName = 'vm-${systemName}-${env}'

// リソース作成
// ネットワークセキュリティグループの作成
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnySSHInbound'
        properties: {
          priority: 100
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'AllowVnetInBound'
        properties: {
          priority: 110
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
        }
      }
    ]
  }
}

// 仮想マシン用パブリックアドレスアドレスの作成
resource pipVM 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: pipVMName
  location: location
  zones: ((length(availabilityZones) == 0) ? null : availabilityZones)
  sku: {
      name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}


// 仮想ネットワークの作成
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: subnets[0].name
        properties: {
          addressPrefix: subnets[0].subnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// ネットワークインターフェイスの作成
resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnets[0].name)
          }
            publicIPAddress: {
            id: pipVM.id
          }
        }
      }
    ]
  }
}

// 仮想マシンの作成
resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: base64(loadTextContent('cloud-init.txt'))
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
