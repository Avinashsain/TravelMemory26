aws_region          = "us-east-1"
project_name        = "travelmemory"
environment         = "production"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

trusted_ip = "47.15.110.107/32"

public_key_path = "~/.ssh/travelmemory.pub"

web_instance_type = "t2.small"
db_instance_type  = "t2.small"
hash_key          = "LockID"
