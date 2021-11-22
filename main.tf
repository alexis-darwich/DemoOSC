terraform {
  required_providers {
    outscale = {
      source  = "outscale-dev/outscale"
      version = "0.2.0"
    }
  }
}

# Configure the OSC provider

provider "outscale" {
  access_key_id = var.access_key_id
  secret_key_id = var.secret_key_id
  region        = var.region
}

# Create Keypair

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "my_key" {
  filename        = "${path.module}/my_key.pem"
  content         = tls_private_key.my_key.private_key_pem
  file_permission = "0600"
}

resource "outscale_keypair" "my_keypair" {
  public_key = tls_private_key.my_key.public_key_openssh
}

# Create a VPC

resource "outscale_net" "net01" {
  ip_range = "10.0.0.0/16"
  tags  {
    key   = "name"
    value = "terraform-net-for-vm"
  }
}

# Create security group for front

resource "outscale_security_group" "security_group_front" {
  description         = "security group for front VM"
  security_group_name = "security-group-front"
  net_id              = outscale_net.net01.net_id
}

# Create security group rules for front

resource "outscale_security_group_rule" "security_group_rule01" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.security_group_front.security_group_id
  from_port_range   = "80"
  to_port_range     = "80"
  ip_protocol       = "tcp"
  ip_range          = "0.0.0.0/0"
}

resource "outscale_security_group_rule" "security_group_rule02" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.security_group_front.security_group_id
  from_port_range   = "22"
  to_port_range     = "22"
  ip_protocol       = "tcp"
  ip_range          = "0.0.0.0/0"
}

# Create security group for back

resource "outscale_security_group" "security_group_back" {
  description         = "security group for back VM"
  security_group_name = "security-group-back"
  net_id              = outscale_net.net01.net_id
}

# Create security group rules for back

resource "outscale_security_group_rule" "security_group_rule03" {
    flow              = "Inbound"
    security_group_id = outscale_security_group.security_group_back.security_group_id
    rules {
     from_port_range   = "22"
     to_port_range     = "22"
     ip_protocol       = "tcp"
     security_groups_members {
        account_id = var.account_id
        security_group_id = outscale_security_group.security_group_front.security_group_id
       }
    }
}

resource "outscale_security_group_rule" "security_group_rule04" {
    flow              = "Inbound"
    security_group_id = outscale_security_group.security_group_back.security_group_id
    rules {
     from_port_range   = "80"
     to_port_range     = "80"
     ip_protocol       = "tcp"
     security_groups_members {
        account_id = var.account_id
        security_group_id = outscale_security_group.security_group_front.security_group_id
       }
    }
}

# Create a front subnet in AZ B

resource "outscale_subnet" "subnet01" {
    net_id         = outscale_net.net01.net_id
    ip_range       = "10.0.1.0/24"
    subregion_name = "eu-west-2b"
    tags {
        key   = "name"
        value = "subnet1-b-front"
      }
}

# Create a front subnet in AZ A

resource "outscale_subnet" "subnet02" {
    net_id         = outscale_net.net01.net_id
    ip_range       = "10.0.2.0/24"
    subregion_name = "eu-west-2a"
    tags {
        key   = "name"
        value = "subnet2-a-front"
      }
}

# Create a back subnet in AZ B

resource "outscale_subnet" "subnet03" {
    net_id         = outscale_net.net01.net_id
    ip_range       = "10.0.3.0/24"
    subregion_name = "eu-west-2b"
    tags {
        key   = "name"
        value = "subnet3-b-back"
      }
}

# Create a back subnet in AZ A

resource "outscale_subnet" "subnet04" {
    net_id         = outscale_net.net01.net_id
    ip_range       = "10.0.4.0/24"
    subregion_name = "eu-west-2a"
    tags {
        key   = "name"
        value = "subnet4-a-back"
      }
}

# Create Route Table for subnet 1 (front)

resource "outscale_route_table" "route_table01" {
  net_id = outscale_net.net01.net_id
  tags {
    key   = "name"
    value = "route-table-for-front-subnet-1"
  }
}

resource "outscale_route_table_link" "route_table_link01" {
  route_table_id = outscale_route_table.route_table01.route_table_id
  subnet_id      = outscale_subnet.subnet01.subnet_id
}

# Create Route Table for subnet 2 (front)

resource "outscale_route_table" "route_table02" {
  net_id = outscale_net.net01.net_id
  tags {
    key   = "name"
    value = "route-table-for-front-subnet-2"
  }
}

resource "outscale_route_table_link" "route_table_link02" {
  route_table_id = outscale_route_table.route_table02.route_table_id
  subnet_id      = outscale_subnet.subnet02.subnet_id
}

# Create Route Table for subnet 3 (back)

resource "outscale_route_table" "route_table03" {
  net_id = outscale_net.net01.net_id
  tags {
    key   = "name"
    value = "route-table-for-back-subnet-3"
  }
}

resource "outscale_route_table_link" "route_table_link03" {
  route_table_id = outscale_route_table.route_table03.route_table_id
  subnet_id      = outscale_subnet.subnet03.subnet_id
}

# Create Route Table for subnet 4 (back)

resource "outscale_route_table" "route_table04" {
  net_id = outscale_net.net01.net_id
  tags {
    key   = "name"
    value = "route-table-for-back-subnet-4"
  }
}

resource "outscale_route_table_link" "route_table_link04" {
  route_table_id = outscale_route_table.route_table03.route_table_id
  subnet_id      = outscale_subnet.subnet04.subnet_id
}

# Create internet service

resource "outscale_internet_service" "internet_service01" {
}

resource "outscale_internet_service_link" "internet_service_link01" {
  internet_service_id = outscale_internet_service.internet_service01.internet_service_id
  net_id              = outscale_net.net01.net_id
}

# Create default route for front

resource "outscale_route" "route01-b-front" {
  gateway_id           = outscale_internet_service.internet_service01.internet_service_id
  destination_ip_range = "0.0.0.0/0"
  route_table_id       = outscale_route_table.route_table01.route_table_id
}

resource "outscale_route" "route02-a-front" {
  gateway_id           = outscale_internet_service.internet_service01.internet_service_id
  destination_ip_range = "0.0.0.0/0"
  route_table_id       = outscale_route_table.route_table02.route_table_id
}

# Create VMs

resource "outscale_vm" "vm01" {
  image_id           = var.image_id
  vm_type            = var.vm_type
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  security_group_ids = [outscale_security_group.security_group_front.security_group_id]
  subnet_id          = outscale_subnet.subnet01.subnet_id
  tags {
    key = "name"
    value = "front-vm1"
  }
}

resource "outscale_vm" "vm02" {
  count              = 1
  image_id           = var.image_id
  vm_type            = var.vm_type
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  security_group_ids = [outscale_security_group.security_group_front.security_group_id]
  subnet_id          = outscale_subnet.subnet02.subnet_id
  tags {
    key = "name"
    value = "front-vm2"
  }
}

resource "outscale_vm" "vm03" {
  image_id           = var.image_id
  vm_type            = var.vm_type
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  security_group_ids = [outscale_security_group.security_group_back.security_group_id]
  subnet_id          = outscale_subnet.subnet03.subnet_id
tags {
    key = "name"
    value = "back-vm3"
  }
}

resource "outscale_vm" "vm04" {
  image_id           = var.image_id
  vm_type            = var.vm_type
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  security_group_ids = [outscale_security_group.security_group_back.security_group_id]
  subnet_id          = outscale_subnet.subnet04.subnet_id
tags {
    key = "name"
    value = "back-vm4"
  }
}
