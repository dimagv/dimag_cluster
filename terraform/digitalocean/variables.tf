variable "token" { 
	default = "" 
}

variable "hostname" {}
variable "image" {
	default = "ubuntu-14-04-x64"
}
variable "region" {
	default = "fra1"
}
variable "size" {
	default = "512mb"
}
variable "private_networking" {
	default = "true"
}

variable "public_key" {
	default = "id_rsa.pub"
}

variable "private_key" {
	default = "id_rsa"
} 

variable "ssh_fingerprint" {}

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
