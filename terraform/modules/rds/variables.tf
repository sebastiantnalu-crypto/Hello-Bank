variable "subnet_ids"        { type = list(string) }
variable "security_group_id" { type = string }
variable "project_name"      { type = string }
variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true 
}