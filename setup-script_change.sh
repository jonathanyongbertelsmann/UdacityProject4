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

az group create \
--name "udacityProject4_rg" \
--location "westus2" \
--verbose

az storage account create --name "udacityprojectsa" --resource-group "udacityProject4_rg" --location "westus2" --sku Standard_LRS

az network nsg create \
--resource-group "udacityProject4_rg" \
--name "udacityproject-vmss-nsg" \
--verbose

az vmss create \
  --resource-group "udacityProject4_rg" \
  --name $vmssName \
  --image $osType \
  --vm-sku $vmSize \
  --nsg "udacityproject-vmss-nsg" \
  --subnet $subnetName \
  --vnet-name $vnetName \
  --backend-pool-name $bePoolName \
  --storage-sku $storageType \
  --load-balancer $lbName \
  --custom-data cloud-init.txt \
  --upgrade-policy-mode automatic \
  --admin-username $adminName \
  --generate-ssh-keys \
  --verbose 

az network vnet subnet update \
--resource-group "udacityProject4_rg" \
--name $subnetName \
--vnet-name $vnetName \
--network-security-group "udacityproject-vmss-nsg" \
--verbose

az network lb probe create \
  --resource-group "udacityProject4_rg" \
  --lb-name $lbName \
  --name $probeName \
  --protocol tcp \
  --port 80 \
  --interval 5 \
  --threshold 2 \
  --verbose

az network lb rule create \
  --resource-group "udacityProject4_rg" \
  --name $lbRule \
  --lb-name $lbName \
  --probe-name $probeName \
  --backend-pool-name $bePoolName \
  --backend-port 80 \
  --frontend-ip-name loadBalancerFrontEnd \
  --frontend-port 80 \
  --protocol tcp \
  --verbose

az network nsg rule create \
--resource-group "udacityProject4_rg" \
--nsg-name "udacityproject-vmss-nsg" \
--name Port_80 \
--destination-port-ranges 80 \
--direction Inbound \
--priority 100 \
--verbose

az network nsg rule create \
--resource-group "udacityProject4_rg" \
--nsg-name "udacityproject-vmss-nsg" \
--name Port_22 \
--destination-port-ranges 22 \
--direction Inbound \
--priority 110 \
--verbose

