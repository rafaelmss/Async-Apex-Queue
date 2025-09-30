# Async Apex Framework – Flex Queue Orchestrator for Salesforce

O **Async Apex Framework** é um orquestrador simples e resiliente para lidar com o limite de **100 jobs na Flex Queue do Salesforce**.  
Ele garante que jobs **Apex Apex** sejam enfileirados de forma controlada, persistindo os excedentes em um objeto customizado e reprocessando-os automaticamente via *Scheduler*.



## Por que usar este framework?

No Salesforce, a Flex Queue permite apenas **100 jobs “Holding”** simultaneamente.  
Ao ultrapassar esse limite, recebemos a exceção:
*System.AsyncException: You have exceeded the limit of 100 jobs in the flex queue.*

Este framework resolve o problema com:
- **Camada de submissão** (`AsyncApexFramework`) → intercepta chamadas a Batch/Queueable e decide se o job será enfileirado ou persistido.  
- **Persistência** (`AsyncJob__c`) → objeto customizado que armazena jobs excedentes com prioridade, payload e política de retry.  
- **Drenagem automática** (`AsyncApexDrainScheduler` + `AsyncApexDrainJob`) → a cada X minutos, jobs pendentes são submetidos orientado pelo limite da Flex Queue (mas pode ser um parâmetro em um parÂmetro customizado como metadado).  



## O que está incluído

- **Objeto Customizado**
  - `AsyncJob__c` → armazena jobs, status, prioridade, payload JSON, tentativas e erros.
- **Apex Classes**
  - `AsyncApexFramework` → API principal de submissão (`submitBatch`, `submitQueueable`, `flush`).
  - `AsyncApexDrainScheduler` → classe agendável para disparar drenagem.
  - `AsyncApexDrainJob` → lógica de reprocessamento por prioridade.
  - Exemplos de uso: `ApexDemo`, `Exemple`.
- **Segurança**
  - Permission Set `Async Apex Framework Admin` → acesso às classes e ao objeto.



## Instalação

Clone este repositório e faça deploy em sua org:

```bash
# Autenticar na org
sf org login web -a MINHA_ORG

# Deploy do projeto
sf project deploy start -o MINHA_ORG
