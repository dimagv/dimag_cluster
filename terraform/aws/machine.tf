resource "aws_instance" "web" {
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${aws_key_pair.default.id}"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    subnet_id = "${aws_subnet.default.id}"
    tags {
        Name = "${var.hostname}"
    }
    
    depends_on = [ "aws_key_pair.default", "aws_security_group.default" ]

    connection {
        user = "ubuntu"
        type = "ssh"
        key_file = "${var.private_key}"
        timeout = "1m"
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
        "ansible-playbook /tmp/ansible/playbook.yml --extra-vars 'remote_user=ubuntu hostname=${var.hostname} public_ip=${aws_instance.web.public_ip} private_ip=${aws_instance.web.private_ip} vault_server_ip=${var.vault_server_ip} consul_master_ip=${var.consul_master_ip}' --extra-vars '@/tmp/ansible/vars/${var.ansible_vars_file}.json'"
      ]
    }
}
