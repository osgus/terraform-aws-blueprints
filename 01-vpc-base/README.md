# 01 — VPC Base

Este modelo de referência provisiona a camada de rede na AWS, projetada para atender a requisitos de alta disponibilidade, isolamento de segurança em múltiplas camadas e governança do remote state.

O objetivo aqui é ter uma base isolada e estável para suportar cargas de trabalho subsequentes (como instâncias EC2, clusters ECS ou bancos de dados relacionais), desacoplando a infraestrutura de rede central das camadas de computação.


## Topologia de Rede e Arquitetura Multi-AZ

A topologia implementa uma (VPC) inicial com duas Zonas de Disponibilidade (`us-east-1a` e `us-east-1b`), segmentada em três camadas distintas para garantir o isolamento do tráfego e a conformidade com o princípio do privilégio mínimo




| Subnet name | Tier | CIDR Block | Availability Zone (AZ) | Routing / Association | 
| ----- | ----- | ----- | ----- | ----- | 
| `pub-subnet-a` | Public | `172.16.10.0/24` | `us-east-1a` | Public Route Table $\rightarrow$ Internet Gateway (IGW) | 
| `pub-subnet-b` | Public | `172.16.20.0/24` | `us-east-1b` | Public Route Table $\rightarrow$ Internet Gateway (IGW) | 
| `priv-app-subnet-a` | Private (App) | `172.16.11.0/24` | `us-east-1a` | Private Route Table (Isolated) | 
| `priv-app-subnet-b` | Private (App) | `172.16.21.0/24` | `us-east-1b` | Private Route Table (Isolated) | 
| `priv-db-subnet-a` | Private (Database) | `172.16.12.0/24` | `us-east-1a` | Private Route Table (Isolated) | 
| `priv-db-subnet-b` | Private (Database) | `172.16.22.0/24` | `us-east-1b` | Private Route Table (Isolated) | 

## Conceitos de rede e segurança aplicados

* **Borda da Rede Externa (Internet Gateway):** O Internet Gateway (IGW) atua como o gateway da VPC para a internet, estando associado estritamente à tabela de rotas da sub-rede pública.

* **Isolamento de Camadas Privadas:** As sub-redes de aplicação e de banco de dados não possuem rotas diretas para o Internet Gateway nem alocação dinâmica de IPv4 público. As cargas de trabalho provisionadas nessas sub-redes não podem ser acessadas diretamente pela internet.

* **Tolerância a falhas entre zonas de disponibilidade (Multi-AZ):** Cada camada oferece redundância em duas zonas de disponibilidade distintas, permitindo projetos tolerantes a falhas contra a perda total de uma zona de disponibilidade individual.


## Padrões de Implementação de IaC

* **Provisionamento Dinâmico de Sub-redes:** Todas as seis sub-redes são gerenciadas por um único bloco de recurso `aws_subnet` que itera sobre um mapa de objetos estruturado definido em `variables.tf`. Isso evita código repetitivo manual e simplifica o gerenciamento das sub-redes.

* **Associações Dinâmica de Rotas :** A associação de sub-redes utiliza filtragem de atributos, assim vincula tabelas de rotas públicas e privadas de forma dinâmica, sem redundância manual.

* **Gerenciamento Centralizado do tfstate:** Os arquivos tfstate  são armazenados remotamente em um backend Amazon S3 com versionamento de bucket habilitado, garantindo a integridade do estado e o rastreamento de alterações.

* **Desacoplamento de Saídas:** Os recursos necessários para módulos subsequentes são exportados por meio do arquivo `outputs.tf` para consumo via `data "terraform_remote_state"`, eliminando dependências fixas (hardcoded) entre camadas.

## Estrutura do Diretorio

```
01-vpc-base/
├── main.tf          # Configuração do provider AWS e backend remote state do S3.
├── variables.tf     # VPC CIDR block and structured subnet object map.
├── network.tf       # VPC, Subnets, IGW, Route Tables, e Associations.
├── outputs.tf       # IDs de VPC e sub-rede exportados.
└── README.md        # Documentação técnica do módulo.

```

## Guia de Execução

### 1. Pré-requisitos

Verifique se o perfil da AWS CLI está configurado e se o bucket S3 de destino para o remote state está disponível:

```
Windows Powershell: Get-Content $env:USERPROFILE\.aws\credentials 

ou

Linux / macOS: cat ~/.aws/credentials ou cat ~/.aws/config

O nome perfil aparacera entre []

```

### 2. Implantação

```
# Inicialize o provider e conecte-se ao back-end remoto S3
terraform init

#Validar plano de execução e recursos propostos
terraform plan -out plan.out

# Aplicar alterações de infraestrutura na AWS
terraform apply "plan.out"

```

## Resultados exportados

Os módulos downstream podem consumir as seguintes saídas usando `data "terraform_remote_state"`:

* `vpc_id`

* `subnet_ids`:

  * `subnet_ids["pub-subnet-a"]`

  * `subnet_ids["pub-subnet-b"]`

  * `subnet_ids["priv-app-subnet-a"]`

  * `subnet_ids["priv-app-subnet-b"]`

  * `subnet_ids["priv-db-subnet-a"]`

  * `subnet_ids["priv-db-subnet-b"]`