
# -------------------------
# ECS Cluster
# -------------------------

resource "aws_ecs_cluster" "main" {
  name = "hemanth-fargate-cluster"
}

# -------------------------
# IAM Role for ECS Tasks
# -------------------------

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
