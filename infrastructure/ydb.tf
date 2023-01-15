resource "yandex_ydb_database_serverless" "database1" {
  name = "fiit-cloud-ydb-serverless"

  deletion_protection = true
}
