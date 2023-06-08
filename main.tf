
resource "aws_vpc" "terraform_demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform_demo_dev_vpc"
  }
}

resource "aws_subnet" "terraform_demo_public_subnet" {
  vpc_id                  = aws_vpc.terraform_demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "terraform_demo_dev_public"
  }
}


resource "aws_internet_gateway" "terraform_demo_igw" {
  vpc_id = aws_vpc.terraform_demo_vpc.id

  tags = {
    Name = "terraform_demo_dev_igw"
  }

}


resource "aws_route_table" "terraform_demo_public_rt" {
  vpc_id = aws_vpc.terraform_demo_vpc.id

  tags = {
    Name = "terraform_demo_public_rt"
  }
}

resource "aws_route" "terraform_default_route" {
  route_table_id         = aws_route_table.terraform_demo_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terraform_demo_igw.id
}

resource "aws_route_table_association" "terraform_public_rt_assoc" {
  subnet_id      = aws_subnet.terraform_demo_public_subnet.id
  route_table_id = aws_route_table.terraform_demo_public_rt.id

}

resource "aws_security_group" "terraform_demo_sg" {
  name        = "terraform_dev_sg"
  description = "Allow web access to instances"
  vpc_id      = aws_vpc.terraform_demo_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_key_pair" "terraform_demo_auth" {
  key_name   = "terraform_demo_key"
  public_key = file("~/.ssh/terraform_demo_key.pub")
}


resource "aws_instance" "terraform_node_server" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.terraform_demo_server_ami.id
  key_name               = aws_key_pair.terraform_demo_auth.id
  vpc_security_group_ids = [aws_security_group.terraform_demo_sg.id]
  subnet_id              = aws_subnet.terraform_demo_public_subnet.id
  user_data              = file("userdata.tpl")


  root_block_device {
    volume_size = 10
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    name = "dev_node"
  }
}



