variable "aws_region" {
    description = "AWS region to deploy everything"
    type        = string
    default = "eu-north-1" 
}

variable "project_name" {
    description= "Used to name all resources"
    type        = string
    default = "hello-bank" 
}

variable "environment" {
    description = "staging or production"
    type        = string
    default = "staging" 
}

variable "db_password" {
  description = "RDS root password"
  type        = string
  sensitive   = true 
}

variable "s3_bucket_name" {
    description = "S3 bucket for app assets"
    type = string
}
