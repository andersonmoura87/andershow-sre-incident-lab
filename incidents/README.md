# Catálogo técnico de incidentes

Este diretório reúne investigações realizadas no Andershow SRE Incident Lab.

Os cenários são simulados e executados em ambientes de laboratório. As conclusões devem ser interpretadas conforme as evidências e limitações documentadas.

## Incidentes documentados

### INC-001 — Saint John

**Domínio:** Linux / Gerenciamento de processos

**Problema:** processo executando escrita contínua em arquivo de log.

**Competências exercitadas:** inspeção de processos, identificação de descritores de arquivo, sinais Unix e validação de remediação.

**Resultado:** checker oficial aprovado. Não foi registrada validação independente após a intervenção na segunda instância.

[Consultar relatório INC-001](001-saint-john/incident-report.md)

### INC-002 — Linux Server Review

**Domínio:** Linux / Aplicações / Banco de dados / Performance

**Problema:** investigação de utilização elevada de CPU, concorrência no PostgreSQL e comportamento de uma aplicação HTTP sob carga.

**Competências exercitadas:** análise de processos, `vmstat`, investigação de locks, consultas ao PostgreSQL, testes HTTP e análise de logs.

**Resultado:** investigação concluída e melhorias pontuais aplicadas. Não houve comprovação estatística de ganho de desempenho nem eliminação do gargalo arquitetural.

[Consultar relatório INC-002](002-linux-server-review/incident-report.md)

### INC-003 — Tokamachi

**Domínio:** Linux IPC / Bash / Controle de fluxo

**Problema:** interrupções ou atrasos no processamento de mensagens transmitidas por uma FIFO.

**Competências exercitadas:** inspeção de named pipes, análise de processos produtores e consumidores, backpressure e validação funcional.

**Resultado:** fluxo estabilizado nas condições testadas; checker oficial aprovado em 6min04s, sem utilização de dicas.

[Consultar relatório INC-003](003-tokamachi/incident-report.md)

### INC-004 — Salta

**Domínio:** Docker / Node.js / Serviços Linux / Redes

**Problema:** aplicação Node.js containerizada indisponível devido a um comando de inicialização incorreto e à ocupação da porta HTTP do host pelo nginx.

**Competências exercitadas:** análise de logs Docker, inspeção de Dockerfile, construção de imagens, diagnóstico de serviços Linux, permissões administrativas e publicação de portas.

**Resultado:** aplicação recuperada conforme os critérios do laboratório; checker oficial aprovado em 9min42s, sem utilização de dicas.

[Consultar relatório INC-004](004-salta/incident-report.md)

## Organização das evidências

Cada diretório de incidente contém:

- `incident-report.md`: investigação, evidências, hipóteses, intervenções, validação e limitações.
- `evidence/`: artefatos complementares, quando disponíveis e apropriados para publicação.

Não devem ser publicados segredos, credenciais, dados pessoais ou informações operacionais sensíveis.

## Padrões de documentação

Os relatórios seguem os princípios definidos na [metodologia](../docs/methodology.md), utilizando o [modelo de incidente](../templates/incident-report.md) e o [checklist de qualidade](../docs/incident-quality-checklist.md).

## Limitações

Os resultados representam exclusivamente as condições dos laboratórios executados.

A conclusão de um exercício não demonstra, por si só, disponibilidade, escalabilidade ou confiabilidade de sistemas reais.
