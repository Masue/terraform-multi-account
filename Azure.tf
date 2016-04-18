
provider "azure" {
  publish_settings = "${file("credentials.publishsettings")}"
}

resource "azure_storage_service" "gluo-blog" {
    name = "gluoblog"
    location = "North Europe"
    description = "Made by Terraform."
    account_type = "Standard_LRS"
}


resource "azure_virtual_network" "default" {
    name = "blog-network"
    address_space = ["10.1.2.0/24"]
    location = "North Europe"

    subnet {
        name = "blognet"
        address_prefix = "10.1.2.0/25"
    }
}


resource "azure_security_group" "dbservers" {
    name = "dbservers"
    location = "North Europe"
}

resource "azure_instance" "MysqlServer" {
    name =   "${var.azure_instance_name}"
    image = "Ubuntu Server 14.04 LTS"
    size = "Basic_A1"
    location = "North Europe"
    username = "${var.azure_instance_username}"
    password = "${var.azure_instance_password}"
    storage_service_name = "gluoblog"
    security_group = "dbservers"
    virtual_network = "blog-network" 
    subnet = "blognet"
    endpoint {
        name = "SSH"
        protocol = "tcp"
        public_port = 22
        private_port = 22
    }
}


resource "azure_security_group_rule" "ssh_access" {
    name = "ssh-access-rule"
    security_group_names = [ "${azure_security_group.dbservers.name}" ]
    type = "Inbound"
    action = "Allow"
    priority = 200
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "${aws_instance.blogpost_nat.public_ip}"
    destination_port_range = "22"
    protocol = "TCP"
}


resource "azure_security_group_rule" "mysql-access" {
    name = "mysql-access-rule"
    security_group_names = ["${azure_security_group.dbservers.name}"] 
    type = "Inbound"
    action = "Allow"
    priority = 300
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "10.0.0.0/32"
    destination_port_range = "80"
    protocol = "TCP"
}


