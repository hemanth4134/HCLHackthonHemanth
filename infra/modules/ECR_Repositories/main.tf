# -------------------------
# ECR Repositories
# -------------------------

resource "aws_ecr_repository" "appointment_service" {
  name = "appointment-phk"
}

resource "aws_ecr_repository" "patient_service" {
  name = "patient-phk"
}

# -------------------------
# Build and Push Docker Images
# -------------------------

resource "null_resource" "docker_build_and_push_appointment_service" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.appointment_service.repository_url}
      docker build -t appointment-phk ./appointment-phk
      docker tag appointment-phk:latest ${aws_ecr_repository.appointment_service.repository_url}:latest
      docker push ${aws_ecr_repository.appointment_service.repository_url}:latest
    EOT
  }
}

resource "null_resource" "docker_build_and_push_patient_service" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.patient_service.repository_url}
      docker build -t patient-phk ./patient-phk
      docker tag patient-phk:latest ${aws_ecr_repository.patient_service.repository_url}:latest
      docker push ${aws_ecr_repository.patient_service.repository_url}:latest
    EOT
  }
}
