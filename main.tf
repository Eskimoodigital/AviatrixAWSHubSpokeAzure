


#Build the AWS Transit 

module "transit_aws_1" {
  source  = "terraform-aviatrix-modules/aws-transit/aviatrix"
  version = "v4.0.3"

  cidr = "10.77.0.0/20"
  region = "eu-central-1"
  account = "Eskimoo"

  name = "avffhub"
  ha_gw = "false"
  instance_size = "t2.micro"

  
}

 #Build the AWS Spokes

module "spoke_aws" {
  source  = "Eskimoodigital/aws-spoke-ec2/aviatrix"
  version = "1.0.14"

  count = 2

  name            = "avffsp${count.index}"
  cidr            = var.spoke_cidrs[count.index]
  region          = "eu-central-1"
  account         = "Eskimoo"
  transit_gw      = "avx-avffhub-transit"
  vpc_subnet_size = "24"

  ha_gw = "false"
  instance_size = "t2.micro"

  ec2_key = "KP_AVI_EC2_SPOKE"
}

#Build the Azure Transit

module "transit_azure_1" {
  source  = "terraform-aviatrix-modules/azure-transit/aviatrix"
  version = "4.0.1"

  cidr = "10.78.0.0/20"
  region = "West Europe"
  account = "EskimooAzure"

  ha_gw = "false"
  name = "avazhub"
  instance_size = "Standard_B1ms"

}


#Build the Azure Spokes

module "spoke_azure_1" {
  # source  = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  # version = "4.0.1"
  source = "github.com/Eskimoodigital/Eskimoo_Tfm_Avi_Azu_Spoke_wVM"

  count = 2

  name = "avazsp${count.index}"
  cidr = var.azure_spoke_cidrs[count.index]
  region = "West Europe"
  account = "EskimooAzure"
  transit_gw = "avx-avazhub-transit"
  vnet_subnet_size = "24"
  ha_gw = "false"
  
  instance_size = "Standard_B1ms"

}
  

#Build the AWS Azure Transit Peering

module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.4"

  transit_gateways = [
    "avx-avazhub-transit",
    "avx-avffhub-transit",
    
  ]

  
}

#Build the Azure VMs


module "vm_azure_1" {
  # source  = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  # version = "4.0.1"
  source = "github.com/Eskimoodigital/module_azure_vm"

  count = 2

  name          = "vmazsp${count.index}"
  cidr          = module.spoke_azure_1[count.index].vnet.subnets[0].subnet_id
  nic_name      = "vmnic${count.index}"
  ip_name       = "vmip${count.index}"
  rg_name       = "vmrg${count.index}"
  publicip_name = "vmpip${count.index}"

  
}
  


