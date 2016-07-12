resource "digitalocean_droplet" "web" {
    image = "${var.image}"
    name = "${var.hostname}"
    region = "${var.region}"
    size = "${var.size}"
    private_networking = "${var.private_networking}"
    ssh_keys = ["${var.ssh_fingerprint}"]
    depends_on = [ "digitalocean_ssh_key.default" ]

    connection {
        user = "root"
        type = "ssh"
        key_file = "${var.private_key}"
        timeout = "2m"
    }
    provisioner "file" {
        source = "${var.ansible_folder}"
        destination = "/tmp/ansible"
    }
    provisioner "remote-exec" {
      inline = [
        "sudo apt-get install -y software-properties-common",
        "sudo apt-add-repository -y ppa:ansible/ansible",
        "sudo apt-get update",
        # "sudo apt-get -y upgrade",
        "sudo apt-get install ansible -y",
        "ansible-playbook /tmp/ansible/playbook.yml --extra-vars 'hostname=${var.hostname} public_ip=${aws_instance.web.public_ip} private_ip=${digitalocean_droplet.web.ipv4_address_private} vault_server_ip=${var.vault_server_ip} consul_master_ip=${var.consul_master_ip}' --extra-vars '@/tmp/ansible/vars/${var.ansible_vars_file}.json'"
      ]
    }
}
