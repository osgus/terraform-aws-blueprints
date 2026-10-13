# Blueprints de Terraform e AWS

A proposta desse projeto é criar e documentar uma arquitetura de infraestrutura seguindo padrões corporativos de modularidade, alta disponibilidade segurança e governança de estado, utilizando Terraform e AWS

o pretenção é separar a camada de rede das demais camadas de computação e dados, permitindo que diferentes cargas de trabalho consumam a infraestrutura base de forma independente.

## Arquitetura Geral
> <Diagrama em construcão...>

O repositório é estruturado em módulos independentes:

| Blueprint | Diretório | Escopo da Arquitetura | Status |
| :--- | :--- | :--- | :--- |
| **01** | [`01-vpc-base`](./01-vpc-base/) | VPC, segmentação de subnets públicas e privadas em Multi-AZ, Internet Gateway, tabelas de rotas e backend remoto. | Completed |
| **02** | | | |
| **03** | | | |
| **04** | | | |

## Pré-requisitos e Backend de Estado (S3)

Para garantir governança e concorrência segura, o tfstate é gerenciado remotamente em um Bucket S3 com versionamento habilitado.

Como o Terraform necessita do backend acessível durante a inicialização, o bucket deve existir previamente na conta AWS antes do comando `terraform init`:

```bash
# 1. Defina o perfil configurado da AWS CLI
export AWS_PROFILE="YOUR-PROFILE"

# 2. Crie o bucket S3 destinado ao remote state
aws s3api create-bucket --bucket "YOUR-BUCKET-TFSTATE" --region us-east-1

# 3. Habilite o versionamento do bucket para segurança do remote state
aws s3api put-bucket-versioning --bucket "YOUR-BUCKET-TFSTATE" --versioning-configuration Status=Enabled
```
