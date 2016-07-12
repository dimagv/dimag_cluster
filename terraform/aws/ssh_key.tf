# Create a new SSH key
resource "aws_key_pair" "default" {
    key_name = "${var.hostname}"
    public_key = "${file(var.public_key)}"
}