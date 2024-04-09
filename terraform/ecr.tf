resource "aws_ecrpublic_repository" "my_repository" {

  repository_name = "sebby-simple-task-app"

  catalog_data {
    about_text        = "Sebbys Simple Task App"
    description       = "Description"
    operating_systems = ["Linux"]
    usage_text        = "Usage Text"
  }

  tags = {
    env = "dev"
  }
}