terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "local_file" "ansible_inventory" {
  content = <<EOF
[all]
vmnginx ansible_host="${yandex_compute_instance.vmnginx.network_interface.0.nat_ip_address}"
vmposts ansible_host="${yandex_compute_instance.vmposts.network_interface.0.ip_address}" ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${yandex_compute_instance.vmnginx.network_interface.0.nat_ip_address}"'
vmgoods ansible_host="${yandex_compute_instance.vmgoods.network_interface.0.ip_address}" ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${yandex_compute_instance.vmnginx.network_interface.0.nat_ip_address}"'


[all:vars]
ansible_user=ubuntu

[private]
vmposts
vmgoods

[public]
vmnginx
EOF

  filename = "${path.module}/playbooks/terraform-inventory"
}

resource "local_file" "nginx_conf" {
  content  = <<-EOT
    events { }

    http {
      server {
        listen 80;

        location /goods {
          proxy_pass http://${yandex_compute_instance.vmgoods.network_interface.0.ip_address}:3001;
        }

        location /posts {
          proxy_pass http://${yandex_compute_instance.vmposts.network_interface.0.ip_address}:3000;
        }

        error_log /var/log/nginx/error.log;
        access_log /var/log/nginx/access.log;
      }
    }
  EOT

  filename = "${path.module}/playbooks/docker-composes/vmnginx/nginx.conf"
}

resource "yandex_compute_instance" "vmnginx" {
  name     = "nginx-server"
  hostname = "nginx"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.post_goods_subnet.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}

resource "yandex_compute_instance" "vmposts" {
  name     = "posts"
  hostname = "posts"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.post_goods_subnet.id
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}

resource "yandex_compute_instance" "vmgoods" {
  name     = "goods"
  hostname = "goods"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.post_goods_subnet.id
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}

resource "yandex_vpc_network" "posts_goods_network" {
  name = "posts-goods-network"
}

resource "yandex_vpc_subnet" "post_goods_subnet" {
  name           = "post-goods-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.posts_goods_network.id
  route_table_id = yandex_vpc_route_table.my-rt.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_vpc_gateway" "internet_gateway" {
  name = "internet-gateway"
}

resource "yandex_vpc_route_table" "my-rt" {
  name       = "my_routes"
  network_id = yandex_vpc_network.posts_goods_network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.internet_gateway.id
  }
}