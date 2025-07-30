# Bicep Sample

## Azure Resource

This includes of the following resources:

- Virtual network
- Network interface
- Virtual machine with
- Network security group
- Public IP address

## OS and Middleware

- Linux (Ubuntu)
- Apache
- MySQL
- PHP

This includes of the following resources:

## SystemConfiguration

![SystemConfiguration](/img/SystemConfiguration.svg)

```
/var/www/html/diary-app/
├── index.php              # 投稿一覧ページ
├── config.php             # DB接続設定
├── db/init.sql            # データベース初期化SQL
├── css/style.css          # スタイル
├── entries/               # 投稿の作成・編集・削除
│   ├── create.php
│   ├── edit.php
│   └── delete.php
└── templates/             # ヘッダー・フッター共通部品
    ├── header.php
    └── footer.php
```

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

4. To Deploy Azure resources, Run the following command.<br>
   ※There should be main.bicep and cloud-init.txt in the current directory.

```bash:bash
az deployment group create --template-file main.bicep --resource-group <your resource group name>

# az deployment group create --template-file main.bicep --resource-group rg-diary-dev
```

5. Upload diary-app.tar.gz to Azure VM.

6. After login into the virtual machine, Run the following command.

```bash:bash
sudo tar -xzvf ~/diary-app.tar.gz -C /var/www/html/

sudo mysql -u root

# MySQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '<your password>';
FLUSH PRIVILEGES;
exit

sudo vim /var/www/html/diary-app/config.php

sudo systemctl restart apache2
```

7 . Enter http://publicIPAddress/diary-app in your browser.

## Notes

- The deployment was tested on windows.
