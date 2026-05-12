variable "project_name" {
  description = "Used to name all Azure resources"
  type        = string
}

variable "azure_region" {
  description = "Azure region — northeurope is closest to eu-north-1"
  type        = string
  default     = "northeurope"
}

variable "environment" {
  description = "staging or production"
  type        = string
  default     = "staging"
}