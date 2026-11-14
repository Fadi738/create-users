terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# ---------- Variables (making the code flexible) ----------

variable "base_dir" {
  description = "The directory where Terraform creates structure and configuration"
  type        = string
  default     = "./output"
}

variable "users" {
  description = "Users that the PowerShell script should create"
  type = list(object({
    name        = string
    description = string
  }))
  default = [
    { name = "kurs-anna", description = "Test user Anna" },
    { name = "kurs-bo", description = "Test user Bo" },
    { name = "kurs-cleo", description = "Test user Cleo" },
  ]
}

# ---------- Resources ----------

# Resource 1: configuration file with the user list (JSON)
resource "local_file" "users_config" {
  filename = "${var.base_dir}/config/users.json"
  content  = jsonencode({ users = var.users })
}

# Resource 2: logs directory (Terraform creates the folder when the file is created)
resource "local_file" "logs_dir" {
  filename = "${var.base_dir}/logs/.gitkeep"
  content  = "Logs from create-users.ps1 are saved here\n"
}

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
  value       = [for u in var.users : u.name]
}