# 03 — Zabbix 8.0 & Amazon RDS Stack

Esse Blueprint provisiona a pilha de aplicação em EC2 e banco de dados em RDS para fim de homologação utilizei o Zabbix,integrando a camada de aplicação a uma instância gerenciada de banco de dados Amazon RDS (MySQL). A arquitetura valida o modelo em três camadas desacopladas, com balanceamento de carga público, computação isolada em sub-redes privadas e banco de dados gerenciado em sub-redes privadas dedicadas.

O objetivo deste template é utilizar Application Load Balancer, instâncias EC2, Elastic IP, NAT Gateway e instância RDS, consumindo de forma transparente a rede provisionada pelo módulo `01-vpc-base`.

---

## Arquitetura de Aplicação e Alocação de Recursos

A infraestrutura consome os recursos de rede do módulo base via `data "terraform_remote_state"` e distribui os componentes entre camadas públicas e privadas:

| Componente | Recurso Terraform | Tier / Localização | Conectividade / Função |
| :--- | :--- | :--- | :--- |
| **Application Load Balancer** | `aws_lb.alb` | Subnets Públicas (`pub-subnet-a`, `pub-subnet-b`) | Ponto de entrada web público (Porta 80 HTTP), distribuindo tráfego para a interface do Zabbix Frontend |
| **Zabbix Application** | `aws_instance.zabbix-app` | Subnet Privada (`priv-app-subnet-a`) | Instância EC2 hospedando Nginx, PHP-FPM, Zabbix Server e Zabbix Agent 2, sem IP público direto |
| **Zabbix Database** | `aws_db_instance.zabbix-db` | Subnets Privadas (`priv-db-subnet-a`, `priv-db-subnet-b`) | Instância Amazon RDS (MySQL) isolada em `db_subnet_group` privado em Multi-AZ |
| **NAT Gateway & EIP** | `aws_nat_gateway.nat` | Subnet Pública (`pub-subnet-a`) | Concede saída à internet para a instância privada instalar dependências e pacotes oficiais do Zabbix. |
| **Injeção de Rota Privada** | `aws_route.private_internet_access` | Tabela de Rotas Privada (`rtb-private`) | Associa a rota padrão `0.0.0.0/0` da tabela privada ao NAT Gateway provisionado sob demanda. |

---

## Conceitos de Rede e Segurança Aplicados

* **Application Load Balancer:** O ALB é o único componente exposto à internet, recebendo tráfego web externo na porta 80 e encaminhando as requisições para o Target Group associado à instância privada do Zabbix.
* **Isolamento de Segurança Encadeado (Least Privilege):** Os Security Groups são correlacionados diretamente via `referenced_security_group_id`:
  * `alb-sg`: Permite entrada na porta 80 a partir da internet (`0.0.0.0/0`).
  * `app-sg`: Permite entrada na porta 80 exclusivamente a partir do Security Group do ALB (`alb-sg`), além da porta 10051 para comunicação com agentes ativos.
  * `db-sg`: Permite entrada na porta 3306 (MySQL) exclusivamente a partir do Security Group da aplicação (`app-sg`).
* **Criptografia em Trânsito (TLS/SSL):** A comunicação entre o backend do Zabbix Server e o Amazon RDS utiliza o certificado de autoridade certificadora oficial da AWS (`global-bundle.pem`), garantindo integridade e conformidade de rede.
* **Saída Segura para Instalações e Atualizações:** O NAT Gateway e seu respectivo Elastic IP são criados apenas enquanto a stack estiver ativa, garantindo conectividade de saída para a execução do script de inicialização (*user_data*).

---

## Padrões de Implementação de IaC

* **Consumo Dinâmico de Remote State:** O módulo lê os identificadores da VPC, das sub-redes e da tabela de rotas privada diretamente do arquivo de estado do S3 gerado pelo `01-vpc-base`, mantendo as camadas completamente desacopladas.
* **Resolução Limpa de Endereçamento do RDS:** O provisionamento consome diretamente o atributo `aws_db_instance.zabbix-db.address`, garantindo a injeção estrita do hostname DNS do banco sem a porta `:3306`.
* **Ciclo de Vida Efêmero e Otimização de Custos:** Ao separar a computação da rede base, todos os recursos com tarifação ativa podem ser provisionados ou totalmente destruídos (`terraform destroy`) sem impactar a topologia e as configurações da VPC.
* **Provisionamento Automatizado via User Data Template:** A instância EC2 executa o script `./docs/zabbix.sh.tftpl`, que automatiza a compilação de locales (`en_US.UTF-8`), a criação da base no RDS, a importação do schema (`server.sql.gz`) e a pré-configuração do frontend, eliminando o assistente manual de instalação web.
* **Dependência Explícita de Saída:** O provisionamento da instância EC2 conta com `depends_on = [aws_nat_gateway.nat, aws_route.private_internet_access, aws_db_instance.zabbix-db]` para assegurar que o script de *user_data* só inicie após o canal de saída do NAT Gateway e a instância de banco estarem operacionais.

---

## Estrutura do Diretorio

```text
03-zabbix-rds-stack/
├── main.tf          # Configuração dos providers, backend remoto S3 e consumo do remote state de 01-vpc-base
├── variables.tf     # Parâmetros de região, perfil AWS, AMIs, instâncias, credenciais e tags
├── network.tf       # Elastic IP, NAT Gateway, injeção de rota e Security Groups (app-sg e db-sg)
├── alb.tf           # Application Load Balancer, Security Group do ALB, Target Group e Listener
├── rds.tf           # Subnet Group (priv-db), Parameter Group e recurso aws_db_instance (MySQL)
├── vm.tf            # Instância EC2 (zabbix-app), associação de user_data template e dependências
├── output.tf        # DNS público do ALB e endereço interno do RDS exportados
├── docs/            # Template de inicialização e automação (zabbix.sh.tftpl)
└── README.md        # Documentação técnica do módulo