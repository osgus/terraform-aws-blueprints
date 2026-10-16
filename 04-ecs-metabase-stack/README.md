# 04 — ECS Fargate & Metabase Stack

Essa Blueprint provisiona uma infraestrutura orquestrada via **AWS ECS Fargate** e integrada a uma instância gerenciada de banco de dados **Amazon RDS (PostgreSQL)** em sub-redes privadas dedicadas

O objetivo deste modelo é utilizar contêineres sem gerenciamento de sistemas operacionais, garantindo alta disponibilidade Multi-AZ, e consumo transparente da infraestrutura de rede provisionada pelo módulo `01-vpc-base`

---

## Arquitetura de Aplicação e Alocação de Recursos

A infraestrutura consome os recursos de rede do módulo base via `data "terraform_remote_state"` e distribui os componentes entre camadas públicas e privadas:

| Componente | Recurso Terraform | Tier / Localização | Conectividade / Função |
| :--- | :--- | :--- | :--- |
| **Application Load Balancer** | `aws_lb.alb` | Subnets Públicas (`pub-subnet-a`, `pub-subnet-b`) | Ponto de entrada web público (Porta 80 HTTP), distribuindo requisições para os contêineres Metabase na porta 3000. |
| **Metabase Tasks (Fargate)** | `aws_ecs_service.metabase` | Subnets Privadas (`priv-app-subnet-a`, `priv-app-subnet-b`) | Tarefas ECS Fargate em Multi-AZ executando a imagem oficial do Metabase, sem IP público atribuído. |
| **Metabase Database (RDS)** | `aws_db_instance.metabase_db` | Subnets Privadas (`priv-db-subnet-a`, `priv-db-subnet-b`) | Instância Amazon RDS PostgreSQL gerenciada, persistindo dados analíticos, usuários e dashboards. |
| **NAT Gateway & EIP** | `aws_nat_gateway.nat` | Subnet Pública (`pub-subnet-a`) | Canal de saída à internet para as tarefas Fargate realizarem o pull da imagem Docker Hub (`metabase/metabase`). |

---

## Conceitos de Rede e Segurança Aplicados

* **Application Load Balancer:** O ALB é o único componente exposto diretamente à internet (Internet Gateway), balanceando o tráfego HTTP público entre os IPs dinâmicos das tarefas Fargate.
* **Afinidade de Sessão (Stickiness):** O Target Group possui afinidade habilitada, evitando inconsistências no carregamento assíncrono.
* **Isolamento de Segurança Encadeado (Least Privilege):** Cada componente gerencia seu próprio Security Group de forma autossuficiente e correlacionada via `referenced_security_group_id`:
  * `alb_sg` (em `alb.tf`): Permite entrada na porta 80 vinda da internet (`0.0.0.0/0`).
  * `ecs_sg` (em `ecs.tf`): Permite entrada na porta 3000 estritamente a partir do `alb_sg`.
  * `db_sg` (em `rds.tf`): Permite entrada na porta 5432 (PostgreSQL) exclusivamente a partir do `ecs_sg` das tarefas Fargate.
* **Saída Segura para Pull de Imagens Públicas:** As tarefas Fargate operam em sub-redes privadas sem IP público. A saída para o Docker Hub ocorre exclusivamente através do NAT Gateway alocado na sub-rede pública.

---

## Padrões de Implementação de IaC

* **Consumo Dinâmico de Remote State:** O módulo lê os IDs da VPC, das sub-redes e da tabela de rotas privada diretamente do arquivo de estado do S3 gerado pelo `01-vpc-base`.
* **Segurança Modularizada por Recurso:** Os Security Groups são declarados localmente dentro de seus respectivos arquivos (`alb.tf`, `ecs.tf`, `rds.tf`), mantendo o `network.tf` enxuto e dedicado à infraestrutura de conectividade e rotas.
* **Orquestração Serverless com ECS Fargate:** Eliminação do gerenciamento de instâncias EC2, patches de sistema operacional ou agentes de contêiner, alocando recursos de CPU e memória sob demanda por tarefa.
* **Escala Horizontal Stateless:** Múltiplas réplicas da aplicação executam concorrentemente conectadas à mesma base PostgreSQL, gerenciando concorrência de inicialização e migrações via travas distribuídas no banco de dados.
* **Resolução Limpa de Endereçamento do RDS:** A Task Definition injeta o atributo `aws_db_instance.metabase_db.address` diretamente na variável `MB_DB_HOST`, evitando portas concatenadas no hostname de conexão.
* **Dependência Explícita de Deployment:** O recurso `aws_ecs_service` inclui `depends_on = [aws_lb_listener.http, aws_nat_gateway.nat, aws_route.private_internet_access, aws_db_instance.metabase_db]`, garantindo que o serviço Fargate só inicie após a rota de saída para o Docker Hub e o banco estarem operacionais.

---

## Estrutura de Diretorio

```text
04-ecs-metabase-stack/
├── main.tf          # Configuração dos providers, backend remoto S3 e consumo do remote state de 01-vpc-base OBS: Lembre-se de alterar o backend S3 e o data "terraform_remote_state" para refletir seu ambiente
├── variables.tf     # Parâmetros de região, perfil AWS, credenciais do banco, alocação de CPU e memória
├── network.tf       # Elastic IP, NAT Gateway e injeção de rota privada na tabela de rotas do 01-vpc-base
├── alb.tf           # Application Load Balancer, Security Group do ALB, Target Group e Listener
├── ecs.tf           # IAM Roles, Log Group CloudWatch, Security Group do ECS, Cluster, Task Definition e Service
├── rds.tf           # Subnet Group, Security Group do RDS e aws_db_instance (PostgreSQL)
├── outputs.tf       # DNS público do ALB
└── README.md        # Documentação técnica do módulo