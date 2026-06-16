# ─────────────────────────────────────────
# Key Pair
# ─────────────────────────────────────────
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}

# ─────────────────────────────────────────
# Web Server EC2 (public subnet)
# ─────────────────────────────────────────
resource "aws_instance" "web" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 15
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3 python3-pip
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh
  EOF

  tags = {
    Name        = "${var.project_name}-web-server"
    Project     = var.project_name
    Environment = var.environment
    Role        = "webserver"
  }
}

# Elastic IP for web server
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name    = "${var.project_name}-web-eip"
    Project = var.project_name
  }
}

# ─────────────────────────────────────────
# Database EC2 (private subnet)
# ─────────────────────────────────────────
resource "aws_instance" "db" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = var.db_instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.db.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3 python3-pip
  EOF

  tags = {
    Name        = "${var.project_name}-db-server"
    Project     = var.project_name
    Environment = var.environment
    Role        = "database"
  }
}