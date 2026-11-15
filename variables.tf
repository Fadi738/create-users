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