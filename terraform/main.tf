data "aws_region" "current" {}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "default-for-az"
    values = [true]
  }
}

data "aws_subnet" "default" {
  count          = length(data.aws_subnet_ids.default.ids)
  default_for_az = true
  id             = tolist(data.aws_subnet_ids.default.ids)[count.index]
}

data "aws_ami" "docker_node" {
  name_regex  = "packer_docker_node"
  owners      = ["self"]
  most_recent = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "allow_http_worldwide" {
  name        = "allow_http_worldwide"
  description = "SG allows worldwide http access "
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "simple_web_app" {
  name               = "simple_web_app"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "simple_web_app" {
  name = aws_iam_role.simple_web_app.name
  role = aws_iam_role.simple_web_app.name
}

resource "aws_iam_role_policy" "cloudwatch_logs_rw" {
  role = aws_iam_role.simple_web_app.id
  name = "CloudWatchLogs_RW"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}
EOF
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "simple_web_app/backend"
  retention_in_days = 5

}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "simple_web_app/nginx"
  retention_in_days = 5

}


resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.simple_web_app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_eip" "simple_web_app" {
  instance = aws_instance.simple_web_app.id
  vpc      = true
}


resource "aws_instance" "simple_web_app" {
  ami                  = data.aws_ami.docker_node.id
  instance_type        = "t3a.small"
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.simple_web_app.name
  root_block_device {
    encrypted = true
  }
  subnet_id              = data.aws_subnet.default[0].id
  vpc_security_group_ids = [aws_security_group.allow_http_worldwide.id]

  tags = {
    Name = "Simple_Web_App"
  }
}
