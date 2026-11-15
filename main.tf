terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
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