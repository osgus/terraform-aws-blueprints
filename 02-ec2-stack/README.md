# 02 — GLPI EC2 Stack

Esee Blueprint provisiona a pilha de aplicação e banco de dados para fim de homologação utilizei o GLPI, para validar a arquitetura das 3 camadas, com balanceamento de carga público, computação isolada em sub-redes privadas e governança de acesso administrativo sem portas expostas.

O objetivo deste template é gerenciar o ciclo de vida dos recursos que geram cobrança contínua (como balanceadores, instâncias EC2, Elastic IP e NAT Gateway), consumindo de forma transparente a rede provisionada pelo módulo `01-vpc-base`.

---

## Arquitetura de Aplicação e Alocação de Recursos

A infraestrutura consome os recursos de rede do módulo base via `data "terraform_remote_state"` e distribui os componentes entre camadas públicas e privadas:

| Componente | Recurso Terraform | Tier / Localização | Conectividade / Função |
| :--- | :--- | :--- | :--- |
| **Application Load Balancer** | `aws_lb.alb` | Subnets Públicas (`pub-subnet-a`, `pub-subnet-b`) | Ponto de entrada web público (Porta 80 HTTP), distribuindo tráfego para a camada de aplicação. |
| **GLPI Application** | `aws_instance.glpi-app` | Subnet Privada (`priv-app-subnet-a`) | Instância EC2 hospedando a aplicação web NGINX/PHP, sem IP público direto. |
| **GLPI Database** | `aws_instance.glpi-db` | Subnet Privada (`priv-db-subnet-a`) | Instância EC2 hospedando a base de dados MariaDB/MySQL isolada. |
| **NAT Gateway & EIP** | `aws_nat_gateway.nat` | Subnet Pública (`pub-subnet-a`) | Concede saída à internet para as instâncias privadas instalarem dependências e pacotes. |
| **Injeção de Rota Privada** | `aws_route.private_internet_access` | Tabela de Rotas Privada (`rtb-private`) | Associa a rota padrão `0.0.0.0/0` da tabela privada ao NAT Gateway provisionado sob demanda. |

---

## Conceitos de Rede e Segurança Aplicados

* **Application Load Balancer:** O ALB é o único componente exposto à internet, recebendo tráfego web externo e encaminhando as requisições para o Target Group associado à instância privada do GLPI.
* **Isolamento de Segurança Encadeado (Least Privilege):** Os Security Groups são correlacionados diretamente via `referenced_security_group_id`:
  * `alb-sg`: Permite entrada na porta 80 a partir da internet (`0.0.0.0/0`).
  * `app-sg`: Permite entrada na porta 80 exclusivamente a partir do Security Group do ALB (`alb-sg`).
  * `db-sg`: Permite entrada na porta 3306 (MySQL/MariaDB) exclusivamente a partir do Security Group da aplicação (`app-sg`).
* **Saída Segura para Instalações e Atualizações:** O NAT Gateway e seu respectivo Elastic IP são criados apenas enquanto a stack estiver ativa, garantindo conectividade de saída para a execução dos scripts de inicialização (*user_data*).

---

## Padrões de Implementação de IaC

* **Consumo Dinâmico de Remote State:** O módulo lê os identificadores da VPC, das sub-redes e da tabela de rotas privada diretamente do arquivo de estado do S3 gerado pelo `01-vpc-base`, mantendo as camadas completamente desacopladas.
* **Ciclo de Vida Efêmero e Otimização de Custos:** Ao separar a computação da rede base, todos os recursos com tarifação ativa podem ser provisionados ou totalmente destruídos (`terraform destroy`) sem impactar a topologia e as configurações da VPC.
* **Provisionamento Automatizado via User Data:** As instâncias executam scripts shell de inicialização (`./docs/glpi-web.sh` e `./docs/glpi-mariadb.sh`) para configuração automática dos serviços durante o primeiro boot.
* **Dependência Explícita de Saída:** O provisionamento das instâncias EC2 conta com `depends_on = [aws_nat_gateway.nat]` para assegurar que os scripts de *user_data* só iniciem o download de pacotes após o canal de saída do NAT Gateway estar operacional.

---

## 📁 Directory Structure

```text
02-glpi-ec2-stack/
├── main.tf          # Configuração dos providers, backend remoto S3 e consumo do remote state de 01-vpc-base OBS: Lembre-se de alterar o backend S3 e o data "terraform_remote_state" para refletir seu ambiente
├── variables.tf     # Parâmetros de região, perfil AWS, AMIs, tipos de instância e tags
├── network.tf       # Elastic IP, NAT Gateway, injeção de rota e Security Groups (app-sg e db-sg)
├── alb.tf           # Application Load Balancer, Security Group do ALB, Target Group e Listener
├── vm.tf            # Instâncias EC2 (glpi-app e glpi-db) e associação de user_data
├── output.tf        # DNS público do ALB e endereços IPs privados internos exportados
├── docs/            # Scripts de automação e configuração (glpi-web.sh e glpi-mariadb.sh)
└── README.md        # Documentação técnica do módulo