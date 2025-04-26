# -------------------------
# ECS Task Definitions
# -------------------------

resource "aws_ecs_task_definition" "appointment_service_task" {
  family                   = "appointment-phk-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([{
    name  = "appointment-phk-container",
    image = "${aws_ecr_repository.appointment_service.repository_url}:latest",
    portMappings = [{
      containerPort = 3001,
      protocol      = "tcp"
    }]
  }])

  depends_on = [null_resource.docker_build_and_push_appointment_service]
}

resource "aws_ecs_task_definition" "patient_service_task" {
  family                   = "patient-phk-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([{
    name  = "patient-phk-container",
    image = "${aws_ecr_repository.patient_service.repository_url}:latest",
    portMappings = [{
      containerPort = 3002,
      protocol      = "tcp"
    }]
  }])

  depends_on = [null_resource.docker_build_and_push_patient_service]
}
