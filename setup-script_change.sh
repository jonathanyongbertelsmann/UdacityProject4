#!/bin/bash

# Variables
resourceGroup="acdnd-c4-project"
location="westus2"
osType="UbuntuLTS"
vmssName="udacityproject-vmss"
adminName="udacityadmin"
storageAccount="udacityprojectsa"
bePoolName="udacityproject-vmss-bepool"
lbName="udacityproject-vmss-lb"
lbRule="udacityproject-vmss-lb-network-rule"
nsgName="udacityproject-vmss-nsg"
vnetName="udacityproject-vmss-vnet"
subnetName="udacityproject-vmss-vnet-subnet"
probeName="tcpProbe"
vmSize="Standard_B1ls"
storageType="Standard_LRS"

az group create --name "udacityProject4_rg" --location "westus2" --verbose

az storage account create --name "udacityprojectsa" --resource-group "udacityProject4_rg" --location "westus2" --sku Standard_LRS

az network nsg create --resource-group "udacityProject4_rg" --name "udacityproject-vmss-nsg" --verbose

az vmss create --resource-group "udacityProject4_rg" --name "udacityproject-vmss" --image "UbuntuLTS" --vm-sku "Standard_B1ls" --nsg "udacityproject-vmss-nsg" --subnet "udacityproject-vmss-vnet-subnet" --vnet-name "udacityproject-vmss-vnet" --backend-pool-name "udacityproject-vmss-bepool" --storage-sku "Standard_LRS" --load-balancer "udacityproject-vmss-lb" --custom-data cloud-init.txt --upgrade-policy-mode automatic --admin-username "udacityadmin" --generate-ssh-keys --verbose 

az network vnet subnet update --resource-group "udacityProject4_rg" --name "udacityproject-vmss-vnet-subnet" --vnet-name "udacityproject-vmss-vnet" --network-security-group "udacityproject-vmss-nsg" --verbose

az network lb probe create --resource-group "udacityProject4_rg" --lb-name "udacityproject-vmss-lb" --name "tcpProbe" --protocol tcp --port 80 --interval 5 --threshold 2 --verbose

az network lb rule create --resource-group "udacityProject4_rg" --name "udacityproject-vmss-lb-network-rule"   --lb-name "udacityproject-vmss-lb" --probe-name "tcpProbe" --backend-pool-name "udacityproject-vmss-bepool" --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --verbose

az network nsg rule create --resource-group "udacityProject4_rg" --nsg-name "udacityproject-vmss-nsg" --name Port_80 --destination-port-ranges 80 --direction Inbound --priority 100 --verbose

az network nsg rule create --resource-group "udacityProject4_rg" --nsg-name "udacityproject-vmss-nsg" --name Port_22 --destination-port-ranges 22 --direction Inbound --priority 110 --verbose

