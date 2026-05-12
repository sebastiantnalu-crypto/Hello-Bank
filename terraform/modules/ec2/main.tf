data "aws_ami"  "amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["al2023-ami-059f32cf6eecf0ef9"] 
    }
}

resource "aws_instance" "app" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    subnet_id = var.subnet_id
    vpc_security_group_ids = [var.security_group_id]
    tags = { Name = "${var.project_name}-server" 
    } 
}