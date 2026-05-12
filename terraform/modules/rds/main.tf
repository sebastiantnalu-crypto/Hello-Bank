resource "aws_db_subnet_group" "main" {
    name = "${var.project_name}-db-subnet"
    subnet_ids = var.subnet_ids 
    tags = {Name = "${var.project_name}-db-subnet" }
}

resource "aws_db_instance" "postgres" { 
    identifier = "${var.project_name}-postgres-db"
    engine = "postgres"
    engine_version = "15.7"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    db_name = "hellobank"
    username = "bankadmin"
    password = var.db_password
    db_subnet_group_name     = aws_db_subnet_group.main.name
    vpc_security_group_ids = [var.security_group_id]
    skip_final_snapshot = true      # makes it easy to delete when learning
    backup_retention_period = 7     #Without backups, RDS snapshots are not retained automatically.
    publicly_accessible = false     #Otherwise your DB could get a public IP depending on subnet routing.
    deletion_protection = false
    storage_encrypted = true
    auto_minor_version_upgrade = true
    tags = {Name = "${var.project_name}-postgres-db"}
}
