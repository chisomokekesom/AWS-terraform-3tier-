data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  user_data = base64encode(<<-EOF
  #!/bin/bash
  dnf update -y
  dnf install -y httpd

  systemctl enable httpd
  systemctl start httpd

  TOKEN=$(curl -X PUT \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
    -s http://169.254.169.254/latest/api/token)

  INSTANCE_ID=$(curl \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    -s http://169.254.169.254/latest/meta-data/instance-id)

  AZ=$(curl \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

  cat <<HTML > /var/www/html/index.html
  <!DOCTYPE html>
  <html>
  <head>
      <title>AWS 3-Tier Application</title>
  </head>
  <body>
      <h1>AWS 3-Tier Application</h1>
      <h2>Infrastructure deployed using Terraform</h2>
      <p>Application server: $INSTANCE_ID</p>
      <p>Availability Zone: $AZ</p>
  </body>
  </html>
  HTML
EOF
  )
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-app-server"
      Project = var.project_name
    }
  }
}


resource "aws_autoscaling_group" "app_asg" {
  name = "${var.project_name}-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]

  target_group_arns = [
    aws_lb_target_group.app_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-server"
    propagate_at_launch = true
  }
}
