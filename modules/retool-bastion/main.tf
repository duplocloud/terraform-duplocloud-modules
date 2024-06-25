locals {
  ami = [
    for image in data.duplocloud_native_host_images.current.images : image
    if length(regexall("Docker-Duplo-.*-AmazonLinux2$", image.name)) > 0
  ][0].image_id
  user_data = <<EOT
#!/bin/bash 

# Login as root
sudo su

# ssh files and directories
RETOOL_SSH_DIR="/home/retool/.ssh"
RETOOL_AUTH_KEYS="$RETOOL_SSH_DIR/authorized_keys"

# create a user with No Password
adduser retool --password NP

# Create the authorized_keys file if it does not exist yet
mkdir -p $RETOOL_SSH_DIR
touch "$RETOOL_AUTH_KEYS"

# add Retool's public key to the file
echo "${var.retool_public_key}" >> $RETOOL_AUTH_KEYS

# Set permissions on the authorized_keys file
chmod 644 $RETOOL_AUTH_KEYS
chown -R retool:retool $RETOOL_SSH_DIR

# retools public key is rsa, make sure it is allowed by sshd
echo -e "PubkeyAcceptedKeyTypes +ssh-rsa\n" >> /etc/ssh/sshd_config
EOT
}

data "duplocloud_native_host_images" "current" {
  tenant_id = var.tenant_id
}

resource "duplocloud_aws_host" "bastion" {
  tenant_id           = var.tenant_id
  friendly_name       = var.name
  image_id            = local.ami
  capacity            = var.capacity
  keypair_type        = 1
  allocated_public_ip = true
  agent_platform      = 4
  zone                = 0
  base64_user_data    = base64encode(local.user_data)
}



