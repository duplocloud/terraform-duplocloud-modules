output "node_ami" {
  value = data.duplocloud_native_host_image.this.image_id
}
