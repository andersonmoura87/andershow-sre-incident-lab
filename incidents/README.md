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

### INC-005 — Manhattan

**Domínio:** Linux / PostgreSQL / Capacidade de armazenamento

**Problema:** o cluster PostgreSQL 14/main não iniciava e a escrita SQL falhava porque o volume montado em `/opt/pgdata` estava sem blocos livres.

**Competências exercitadas:** leitura de unidade systemd, `pg_lsclusters`, log do PostgreSQL, separação entre blocos e inodes, comparação entre o diretório de dados e arquivos adjacentes, e validação funcional da escrita.

**Resultado:** escrita recuperada conforme os critérios do laboratório; checker oficial aprovado em 13min49s, sem utilização de dicas. A liberação de espaço por `truncate` ficou restrita ao ambiente descartável.

[Consultar relatório INC-005](005-manhattan/incident-report.md)

### INC-006 — Tokyo

**Domínio:** Linux / Apache HTTP Server / Firewall / Permissões

**Problema:** o arquivo web não era entregue ao cliente local. Uma regra da cadeia `INPUT` descartava TCP/80 e, depois da remoção dessa regra, o modo `600` de `index.html` produzia HTTP 403 para o atendimento como `www-data`.

**Competências exercitadas:** reprodução com `curl`, leitura de unidade e socket, verificação de loopback, diagnóstico de `iptables` e `nft`, interpretação de HTTP 403 e permissões Unix.

**Resultado:** arquivo servido conforme os critérios do laboratório; checker oficial aprovado em 8min25s, sem utilização de dicas. As duas correções ficaram restritas ao ambiente descartável.

[Consultar relatório INC-006](006-tokyo/incident-report.md)

### INC-007 — Sumé

**Domínio:** Linux / Knot DNS / DNS autoritativo / Nginx

**Problema:** `blog.sadservers.internal` e `api.sadservers.internal` não resolviam. A zona do Knot não carregava por dados inválidos, enquanto os serviços HTTP respondiam quando o DNS era contornado.

**Competências exercitadas:** separação entre resolução e HTTP, leitura de `SERVFAIL` e EDE, diagnóstico de zona Knot, teste com `curl --resolve`, backup antes da edição e validação por `zone-check`, serial e consulta DNS.

**Resultado:** zona carregada e nomes resolvidos conforme os critérios do laboratório; checker oficial aprovado em 10min33s, sem utilização de dicas. A edição da zona ficou restrita ao ambiente descartável. A saída literal dos `curl` finais não foi preservada.

[Consultar relatório INC-007](007-sume/incident-report.md)

### INC-008 — Singara

**Domínio:** Linux / Docker / containerd / K3s / Kubernetes / Flask

**Problema:** o Deployment `webapp-deployment` permanecia `0/1` porque `webapp:latest` existia no Docker Engine e não no runtime do K3s. Depois da importação, o Service não selecionava o pod e o `containerPort` divergia da porta do Flask.

**Competências exercitadas:** eventos de `ImagePullBackOff`, comparação entre Docker e containerd, importação para o namespace `k8s.io`, selector de Service, distinção entre portas declaradas e a porta do processo, e separação entre checker e testes independentes.

**Resultado:** aplicação recuperada conforme os critérios do laboratório; checker oficial aprovado em 13min35s, sem utilização de dicas. O HTTP pelo NodePort foi medido antes do rollout final. O acesso à porta 8888 do host não foi comprovado. A importação da imagem ficou restrita ao ambiente descartável.

[Consultar relatório INC-008](008-singara/incident-report.md)

### INC-009 — Parma

**Domínio:** Linux / Terraform / provider `hashicorp/local`

**Problema:** `terraform plan` não rodava porque `required_version` pedia `~> 1.12.0` e o Core era 1.9.8. Depois dessa correção, o `validate` revelou um ciclo entre dois `local_file`. O marcador `/var/local/platform-status.txt` estava ausente.

**Competências exercitadas:** restrição de versão do Terraform, leitura do ciclo no HCL, busca de estado local, revisão do plano antes do `apply`, permissão declarada e convergência com um segundo `plan`.

**Resultado:** marcador publicado e plano sem alterações; aceite oficial em 8min49s, sem utilização de dicas. A permissão no filesystem não foi lida com `stat`. O rollback não foi executado. A aprovação veio da interface, sem checker no terminal.

[Consultar relatório INC-009](009-parma/incident-report.md)

## Organização das evidências

Cada diretório de incidente contém:

- `incident-report.md`: investigação, evidências, hipóteses, intervenções, validação e limitações.
- `evidence/`: artefatos complementares, quando disponíveis e apropriados para publicação.

Não devem ser publicados segredos, credenciais, dados pessoais ou informações operacionais sensíveis.

## Padrões de documentação

Os relatórios seguem os princípios definidos na [metodologia](../docs/methodology.md) e no [checklist de qualidade](../docs/incident-quality-checklist.md).

Relatório novo usa o [modelo v2](../templates/incident-report.md) e começa com `<!-- template: v2 -->` na primeira linha. O INC-008 é o primeiro relatório nesse modelo. O INC-009 segue o mesmo modelo. Os relatórios INC-001 a INC-007 permanecem no formato em que foram publicados. O [modelo v1](../templates/incident-report-v1.md) fica preservado como referência desse formato.

## Limitações

Os resultados representam exclusivamente as condições dos laboratórios executados.

A conclusão de um exercício não demonstra, por si só, disponibilidade, escalabilidade ou confiabilidade de sistemas reais.
