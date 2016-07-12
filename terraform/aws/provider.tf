provider "aws" {
    shared_credentials_file = "${var.shared_credentials_file}"
    # access_key = "${var.aws_access_key}"
    # secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}