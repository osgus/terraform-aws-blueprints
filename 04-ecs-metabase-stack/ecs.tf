# Security Group do ECS Fargate
resource "aws_security_group" "ecs_sg" {
  name        = "metabase-ecs-sg"
  description = "ALB-FARGATE-3000"
  vpc_id      = data.terraform_remote_state.vpc-base.outputs.vpc_id

  ingress {
    description     = " HTTP-ALB-3000"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Saida para a Internet via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "metabase-ecs-sg"
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "metabase-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/metabase"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "cluster" {
  name = "metabase-cluster"
}

resource "aws_ecs_task_definition" "metabase" {
  family                   = "metabase-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.metabase_cpu
  memory                   = var.metabase_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "metabase"
      image     = "metabase/metabase:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "MB_DB_TYPE", value = var.db_engine },
        { name = "MB_DB_DBNAME", value = var.db_name },
        { name = "MB_DB_PORT", value = "5432" },
        { name = "MB_DB_USER", value = var.db_username },
        { name = "MB_DB_PASS", value = var.db_password },
        { name = "MB_DB_HOST", value = aws_db_instance.metabase_db.address }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "metabase" {
  name            = "metabase-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.metabase.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-app-subnet-a"],
      data.terraform_remote_state.vpc-base.outputs.subnet_ids["priv-app-subnet-b"]
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.metabase_tg.arn
    container_name   = "metabase"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_nat_gateway.nat,
    aws_route.private_internet_access,
    aws_db_instance.metabase_db
  ]
}