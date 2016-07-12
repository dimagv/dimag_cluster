variable "hostname" {}

variable "aws_access_key" {
	default = ""
}

variable "aws_secret_key" {
	default = ""
}

variable "shared_credentials_file" {
	default = "creds"
}

variable "aws_region" {
	default = "eu-west-1"
}

variable "instance_type" {
	default = "t2.micro"
}

# Ubuntu Server 14.04 LTS (HVM)
variable "aws_amis" {
	default = {
		eu-west-1 = "ami-f95ef58a"
		us-east-1 = "ami-fce3c696"
		us-west-1 = "ami-06116566"
		us-west-2 = "ami-9abea4fb"
		eu-central-1 = "ami-87564feb"
	}
}

variable "public_key" {
	default = "id_rsa.pub"
}

variable "private_key" {
	default = "id_rsa"
} 

variable "ansible_folder" {
	default = "../../ansible"
}

variable "ansible_vars_file" {
	default = "default"
}

variable "consul_master_ip" {
	default = ""
}

variable "vault_server_ip" {
	default = ""
}
