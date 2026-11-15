# ---------- Outputs (displays the provisioning result) ----------

output "config_file" {
  description = "Path to the configuration file that PowerShell reads"
  value       = local_file.users_config.filename
}

output "logs_directory" {
  description = "The directory where PowerShell writes its log file"
  value       = dirname(local_file.logs_dir.filename)
}

output "users_to_create" {
  description = "Users to be created by PowerShell"
  value       = [for u in local.users : u.name]
}