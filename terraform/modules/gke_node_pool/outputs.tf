output "node_pool_name" {
  description = "Name of the node pool"
  value       = google_container_node_pool.primary.name
}

output "node_pool_id" {
  description = "ID of the node pool"
  value       = google_container_node_pool.primary.id
}

output "instance_group_urls" {
  description = "List of instance group URLs"
  value       = google_container_node_pool.primary.instance_group_urls
}
