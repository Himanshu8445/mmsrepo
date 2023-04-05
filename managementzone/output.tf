output "resourcegroup" {
  value     = module.resourcegroup
  sensitive = true
}

output "storage_acct" {
  value     = module.storage_acct
  sensitive = true
}

output "loganalytics" {
  value     = module.loganalytics
  sensitive = true
}

output "key-vault" {
  value     = module.key-vault
  sensitive = true
}