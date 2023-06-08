

data "aws_ami" "terraform_demo_server_ami" {
  most_recent = true
  owners      = ["925975727637"]

  filter {
    name   = "name"
    values = ["ZytbImg010422"]
  }
}
