# Create a new SSH key
resource "digitalocean_ssh_key" "default" {
    name = "${var.hostname}"
    public_key = "${file(var.public_key)}"
}