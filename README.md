# Bicep Sample

## Azure Resource

This includes of the following resources:

- Virtual network
- Network interface
- Virtual machine with
- Network security group

## SystemConfiguration

-

## Instructions

Make sure have the [Azure CLI and Bicep](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/install)

1. Update parameter in main.bicep
2. To log in Azure, Run the following command.

```bash:bash
az login

az account show
```

3. To Create resource group, Run the following command.

```bash:bash
az group create --name <your resource group name> --location <location>

# az group create --name rg-diary-dev --location japaneast
```

4. To Deploy Azure resources, Run the following command.
   ※There should be main.bicep and cloud-init.txt in the current directory.

```bash:bash
az deployment group create --template-file main.bicep --resource-group <your resource group name>

# az deployment group create --template-file main.bicep --resource-group rg-diary-dev
```

5. Upload diary-app.tar.gz to Azure VM.

6. After logging into the virtual machine, Run the following command.

```bash:bash
sudo tar -xzvf ~/diary-app.tar.gz -C /var/www/html/

sudo mysql -u root
```

## Notes

- The deployment was tested on windows.
