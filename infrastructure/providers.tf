terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.84.0"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = "b1ggu7d5e9qi9k2ounr0"
  folder_id = var.folder_id
  #  zone      = "ru-central1-a"
}
