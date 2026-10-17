# Andershow SRE Incident Lab

Laboratório público de investigação e recuperação de incidentes simulados em Linux, aplicações e plataformas.

> **Escopo:** exercícios educacionais em ambientes efêmeros. Os resultados não representam incidentes reais de produção.

## Princípios

- Evidência antes de conclusão; distinguir observação, hipótese e causa confirmada.
- Mudanças mínimas, reversíveis e validadas.
- Não publicar segredos, IPs privados desnecessários ou dados pessoais.
- Relatórios em português; comandos e saídas preservados no idioma original.
- Métricas de desempenho apenas com contexto, carga e método de medição.

## Catálogo de incidentes

| ID | Cenário | Tecnologias | Resultado | Relatório |
|---|---|---|---|---|
| INC-001 | Saint John — escrita contínua em log | Linux, processos, sinais, descritores de arquivo | Resolvido; checker oficial aprovado | [Consultar INC-001](incidents/001-saint-john/incident-report.md) |
| INC-002 | Linux Server Review — investigação de desempenho | Linux, PostgreSQL, Flask, HAProxy, HTTP | Investigação concluída; gargalo arquitetural não resolvido | [Consultar INC-002](incidents/002-linux-server-review/incident-report.md) |
| INC-003 | Tokamachi — controle de fluxo em named pipe | Bash, FIFO, IPC, backpressure | Resolvido; checker oficial aprovado | [Consultar INC-003](incidents/003-tokamachi/incident-report.md) |
| INC-004 | Salta — falha na inicialização de aplicação Node.js | Docker, Node.js, nginx, portas TCP | Resolvido; checker oficial aprovado | [Consultar INC-004](incidents/004-salta/incident-report.md) |
| INC-005 | Manhattan — falha de escrita no PostgreSQL | Linux, PostgreSQL, capacidade de disco | Resolvido; checker oficial aprovado | [Consultar INC-005](incidents/005-manhattan/incident-report.md) |
| INC-006 | Tokyo — arquivo web inacessível | Apache HTTP Server, Linux, firewall, permissões | Resolvido; checker oficial aprovado | [Consultar INC-006](incidents/006-tokyo/incident-report.md) |

Os relatórios distinguem observações, hipóteses, intervenções, validações e limitações. A aprovação de um checker confirma os critérios do laboratório, não a confiabilidade de uma solução em produção.

## Navegação

- [Catálogo técnico de incidentes](incidents/README.md)
- [Modelo de relatório](templates/incident-report.md)
- [Metodologia de investigação](docs/methodology.md)
- [Checklist de qualidade dos incidentes](docs/incident-quality-checklist.md)
- [Runbooks](runbooks/README.md)

## Próximos passos

Escolher o próximo cenário na abertura do exercício. Priorizar observabilidade, capacidade ou recuperação de serviço, e manter o registro do laboratório separado de qualquer proposta ainda não implementada.
