resource "aws_ecr_repository" "weedchart_ecr" {
  name                 = "weedchart_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}