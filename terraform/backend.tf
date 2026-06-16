resource "aws_dynamodb_table" "terraform_lock" {
  name         = "travelmemory-terraform-lock" # hardcoded, must match backend block
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name    = "${var.project_name}-terraform-lock"
    Project = var.project_name
  }
}