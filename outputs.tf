output "vmnginx_private_ip" {
  value = yandex_compute_instance.vmnginx.network_interface.0.ip_address
}

output "vmnginx_public_ip" {
  value = yandex_compute_instance.vmnginx.network_interface.0.nat_ip_address
}

output "vmposts_private_ip" {
  value = yandex_compute_instance.vmposts.network_interface.0.ip_address
}

output "vmgoods_private_ip" {
  value = yandex_compute_instance.vmgoods.network_interface.0.ip_address
}

output "internet_gateway" {
  value = yandex_vpc_gateway.internet_gateway.id
}



