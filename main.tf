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

variable "users_file" {
  description = "CSV file with the users to create (columns: name,description)"
  type        = string
  default     = "./users.csv"
}

# ---------- Locals ----------

# Read the CSV file and turn every row into an object with name and description
locals {
  users = csvdecode(file(var.users_file))
}

# ---------- Resources ----------

# Resource 1: configuration file with the user list (JSON)
resource "local_file" "users_config" {
  filename = "${var.base_dir}/config/users.json"
  content  = jsonencode({ users = local.users })
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
  value       = [for u in local.users : u.name]
}