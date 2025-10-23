output "firewall_rules" {
  description = "List of firewall rule names created"
  value = concat(
    [
      google_compute_firewall.allow_internal.name,
      google_compute_firewall.allow_master_to_nodes.name,
      google_compute_firewall.allow_health_checks.name,
      google_compute_firewall.deny_all.name,
    ],
    var.enable_ssh ? [google_compute_firewall.allow_iap_ssh[0].name] : []
  )
}
