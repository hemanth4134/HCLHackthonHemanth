provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc-hemanthfinal"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-gateway-hemanthfinal"
  }
}

# Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1-hemanthfinal"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2-hemanthfinal"
  }
}

# Private Subnet (optional)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-hemanthfinal"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table-hemanthfinal"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg-hemanthfinal"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "hemanth-fargate-cluster"
}

# IAM Role for Task Execution
resource "aws_iam_role" "ecs_task_exec_role" {
  name = "ecsTaskExecutionRole-hemanth"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECR Repository
# resource "aws_ecr_repository" "phk_app" {
#   name = "phk-app"
# }

# data "aws_caller_identity" "current" {}

# data "aws_region" "current" {}

# # Build and Push Docker Image
# resource "null_resource" "docker_build_and_push" {
#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Logging into ECR..."
#       aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com

#       echo "Building Docker image..."
#       docker build -t phk-app .

#       echo "Tagging Docker image..."
#       docker tag phk-app:latest ${aws_ecr_repository.phk_app.repository_url}:latest

#       echo "Pushing Docker image to ECR..."
#       docker push ${aws_ecr_repository.phk_app.repository_url}:latest
#     EOT
#   }

#   depends_on = [aws_ecr_repository.phk_app]
# }
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}


resource "aws_codebuild_project" "phk_app_build" {
  name          = "phk-app-build"
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0" # Amazon-provided Docker image
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB" # or "CODECOMMIT" or "S3"
    location        = "https://github.com/your-repo/phk-app.git"
    buildspec       = "buildspec.yml"  # 👈 here we call buildspec.yml
  }

  environment_variables {
    name  = "ENVIRONMENT"
    value = "dev"
  }

  tags = {
    Environment = "dev"
  }
}


# Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "fargate-task-hemanth"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([{
    name      = "phk-app-container",
    image     = "${aws_ecr_repository.phk_app.repository_url}:latest",
    portMappings = [{
      containerPort = 80,
      hostPort      = 80,
      protocol      = "tcp"
    }]
  }])

  depends_on = [null_resource.docker_build_and_push]
}

# Load Balancer
resource "aws_lb" "app_lb" {
  name               = "ecs-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name        = "ecs-app-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "fargate-service-hemanth"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "phk-app-container"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.app_listener,
    aws_iam_role_policy_attachment.ecs_exec_attach,
    null_resource.docker_build_and_push
  ]
}
