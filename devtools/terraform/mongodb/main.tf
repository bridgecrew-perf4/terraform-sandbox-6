resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.default.public_key_openssh
}


data "aws_ami" "default" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami_search
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = var.owners

}

resource "aws_instance" "server" {

    count = var.server_count
    ami = data.aws_ami.default.id
    instance_type = var.instance_type
    key_name      = aws_key_pair.generated_key.key_name
    vpc_security_group_ids  = split(",",var.security_group_ids)
    subnet_id = var.subnet_id
    associate_public_ip_address = true
    source_dest_check = false

    root_block_device {
        volume_size = var.volume_size
    }

    tags = {
        Name = "${var.server_name_base}-${format("%02d", count.index+1)}"
    }
}

