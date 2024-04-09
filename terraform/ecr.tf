resource "aws_ecr_repository" "my_repository" {
  name                 = "sebby-simple-task-app" 
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }


}
