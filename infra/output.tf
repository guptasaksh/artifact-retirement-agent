// outputs.tf
output "resource_group_name" {
  value = module.resource_group.name
}

output "container_app_url" {
  value = module.container_app.latest_revision_fqdn
  description = "Public URL of the deployed Container App"
}

output "log_workspace_id" {
  value = module.log_analytics.id
}