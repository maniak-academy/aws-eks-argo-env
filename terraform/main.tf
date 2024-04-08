
terraform {
  required_version = ">= 1.1.0"

}



data "aws_availability_zones" "available" {
  state = "available"
}
