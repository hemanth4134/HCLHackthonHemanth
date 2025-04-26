# -------------------------
# ECS Services
# -------------------------

resource "aws_ecs_service" "appointment_service" {
  name            = "appointment-phk"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.appointment_service_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.appointment_service_tg.arn
    container_name   = "appointment-phk-container"
    container_port   = 3001
  }
}

resource "aws_ecs_service" "patient_service" {
  name            = "patient-phk"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.patient_service_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.patient_service_tg.arn
    container_name   = "patient-phk-container"
    container_port   = 3002
  }
}
