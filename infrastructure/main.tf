data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

data "yandex_vpc_network" "default" {
  name      = "default"
  folder_id = var.folder_id
}

data "yandex_vpc_subnet" "default" {
  name      = "default-ru-central1-a"
  folder_id = var.folder_id
}

data "yandex_iam_service_account" "admin" {
  name      = "admin"
  folder_id = var.folder_id
}

resource "yandex_iam_service_account_key" "sa-auth-key" {
  service_account_id = data.yandex_iam_service_account.admin.id
  description        = "key for service account"
  key_algorithm      = "RSA_4096"
}

resource "yandex_kms_symmetric_key" "admin-kms-key" {
  name              = "admin-key"
  default_algorithm = "AES_256"
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
  symmetric_key_id = yandex_kms_symmetric_key.admin-kms-key.id
  role             = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${data.yandex_iam_service_account.admin.id}",
  ]
}


resource "yandex_compute_instance_group" "ig-with-coi" {
  name               = "ig-with-coi"
  folder_id          = var.folder_id
  service_account_id = data.yandex_iam_service_account.admin.id

  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.container-optimized-image.id
      }
    }
    network_interface {
      network_id = data.yandex_vpc_network.default.id
      subnet_ids = [data.yandex_vpc_subnet.default.id]
      nat        = true
    }
    metadata = {
      user-data                    = file("${path.module}/cloud_config.yml")
      docker-container-declaration = file("${path.module}/declaration.yml")

    }
    service_account_id = data.yandex_iam_service_account.admin.id
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name = "nlb-tg"
  }
}

resource "yandex_lb_network_load_balancer" "load-balancer" {
  name = "nlb-1"
  listener {
    name = "nlb-listener"
    port = 8000
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-with-coi.load_balancer[0].target_group_id
    healthcheck {
      name                = "health-check-1"
      unhealthy_threshold = 5
      healthy_threshold   = 5
      http_options {
        path = "/"
        port = 8000
      }
    }
  }
}

resource "yandex_container_registry" "default" {
  name = "fiit-cloud-nichuse"
}
