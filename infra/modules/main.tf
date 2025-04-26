module "vpc" {
  source = "./modules/VPC_and_Networking"
}

module "ecr" {
  source = "./modules/ECR_Repositories"
}

module "ecs_cluster" {
  source = "./modules/ECS_Cluster_with_Iam_ecs_tasks"
}

module "load_balancers" {
  source = "./modules/Load_balancers"
}

module "task_definitions" {
  source = "./modules/ECS_Task_Definitions"
}

module "ecs_services" {
  source = "./modules/ecs_services"
}
