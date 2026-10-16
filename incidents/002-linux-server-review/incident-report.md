# INC-002 — Linux Server Review: investigação de desempenho

**Ambiente:** SadServers — Debian 11
**Classificação:** Laboratório de troubleshooting / Performance Investigation
**Status:** Investigação concluída; melhorias pontuais aplicadas; gargalo arquitetural não resolvido
**Validação oficial:** Não disponível neste cenário

## 1. Resumo executivo

Foi realizada uma investigação de desempenho em um servidor Linux executando uma aplicação Flask integrada ao PostgreSQL, com HAProxy e um gerador de carga HTTP (`wrk`).

A análise identificou elevada utilização de CPU, espera por transações no PostgreSQL e um padrão de atualização concorrente sobre uma única linha da tabela `traffic`.

Foram aplicadas melhorias no código da aplicação e na configuração de logging. Após as alterações, o serviço permaneceu operacional, mas os testes não demonstraram uma melhoria de desempenho conclusiva.

**Conclusão:** a contenção sobre um registro compartilhado permaneceu como limitação arquitetural relevante.

## 2. Contexto técnico

Componentes identificados durante a investigação:

| Componente | Função observada |
|---|---|
| Debian 11 | Sistema operacional |
| Flask / `webapp.py` | Aplicação HTTP |
| PostgreSQL | Banco de dados da aplicação |
| HAProxy | Componente de proxy HTTP |
| `wrk` | Gerador contínuo de carga |
| systemd | Gerenciamento do serviço `webapp.service` |
| journald | Coleta de logs do serviço |

O processo `wrk` executava requisições continuamente contra `http://127.0.0.1:8000`.

O código da aplicação abria uma conexão PostgreSQL por requisição e executava uma atualização do contador.

## 3. Sintomas e impacto observado

Durante a investigação foram identificados:

- Utilização elevada de CPU, com amostras de apenas 0–1% de ociosidade.
- Aplicação Python entre os processos com maior consumo de CPU.
- Sessões PostgreSQL aguardando eventos de lock do tipo `transactionid`.
- Latência HTTP média próxima de 390 ms no teste inicial.
- Geração intensa de logs de acesso HTTP.
- Evento histórico de OOM Killer envolvendo o processo `stress`.

**Limitação:** não foram coletados dados de usuários reais, SLAs de produção ou indicadores de impacto financeiro. O ambiente era simulado.

## 4. Evidências e investigação

### 4.1. Saturação de CPU

Comando utilizado:

```bash
vmstat 1 6
```

As amostras posteriores à primeira indicaram utilização de CPU próxima de 100%, com elevada participação de tempo de usuário e sistema.

Isso demonstrou pressão computacional durante a carga, mas não identificou isoladamente a causa de todo o consumo.

### 4.2. Concorrência no PostgreSQL

Consultas a `pg_stat_activity` identificaram sessões aguardando locks associados a transações.

A análise de `pg_blocking_pids` também apontou bloqueadores em uma das amostras.

Uma consulta posterior apresentou espera por `transactionid`, mas não retornou bloqueadores naquele instante, evidenciando o caráter transitório dessas observações.

### 4.3. Contador compartilhado

Foi confirmado que a tabela `traffic` continha apenas uma linha.

A aplicação executava:

```sql
UPDATE traffic
SET counter = counter + 1;
```

Esse padrão obriga atualizações concorrentes da mesma linha a aguardarem a liberação dos locks necessários.

A adição de CPUs não elimina essa dependência de serialização.

### 4.4. Sobrecarga de logging

O serviço registrava grande quantidade de requisições HTTP com status 200.

Uma consulta ao journald retornou 9.414 linhas no intervalo solicitado de um minuto.

Esse volume justificou investigar o custo de logging, embora sua contribuição exata para a saturação não tenha sido isolada experimentalmente.

## 5. Intervenções realizadas

### 5.1. Refatoração da operação no banco

O handler foi alterado para utilizar:

```sql
UPDATE traffic
SET counter = counter + 1
RETURNING counter;
```

A implementação também passou a utilizar context managers para a transação e o cursor, além de tratamento de exceções com resposta HTTP 500.

**Benefício esperado:** simplificar a operação, evitar uma consulta separada para obter o contador e melhorar o gerenciamento de recursos.

**Limitação:** a atualização continua incidindo sobre a mesma linha.

### 5.2. Redução de logs de acesso

O nível de logging do Werkzeug foi alterado para `ERROR`.

Após reiniciar o serviço, uma verificação pelo PID do novo processo não encontrou registros de acesso `GET / HTTP` no journald.

Isso confirmou a redução de logs de acesso no processo verificado, mas não demonstrou, isoladamente, redução relevante de CPU.

### 5.3. Reinicialização e verificação funcional

O serviço foi reiniciado por meio do systemd.

A verificação com `curl` retornou HTTP 200 e um valor numérico correspondente ao contador.

## 6. Comparação de desempenho

Os testes foram realizados com:

```bash
wrk -t2 -c50 -d15s http://127.0.0.1:8000/
```

| Etapa | Throughput | Latência média |
|---|---:|---:|
| Antes das alterações | 126,19 req/s | 390,54 ms |
| Após refatoração | 130,13 req/s | 379,41 ms |
| Após redução de logging | 130,81 req/s | 376,39 ms |

Entre a primeira e a última medição, o throughput observado aumentou aproximadamente 3,7%.

Entretanto, os testes tiveram duração curta, foram executados sob carga concorrente e não incluíram repetições suficientes para estabelecer significância estatística.

**Não é possível atribuir causalmente essa diferença às intervenções realizadas.**

## 7. Análise causal

### Evidências confirmadas

- A aplicação atualizava um contador compartilhado.
- A tabela possuía apenas uma linha.
- Foram observadas esperas por transações no PostgreSQL.
- A CPU apresentou saturação durante as medições.
- A aplicação permaneceu funcional após as alterações.

### Interpretação técnica

A atualização concorrente de uma única linha constitui um ponto de contenção que limita a escalabilidade da operação.

Esse mecanismo é consistente com os eventos de espera observados no PostgreSQL.

Entretanto, não foi comprovado que essa contenção fosse responsável por toda a latência ou pela totalidade do consumo de CPU.

### Questões não resolvidas

- Participação exata do custo de criação de conexões no tempo total das requisições.
- Contribuição específica do logging para o consumo de CPU.
- Comportamento do serviço em testes mais longos e repetidos.
- Efeito de uma alteração arquitetural que elimine o contador compartilhado.

## 8. Recomendações

**Prioridade 1 — Medição e observabilidade**

Estabelecer testes repetíveis, métricas de latência por percentis, throughput, erros HTTP, utilização de CPU e tempo de espera por locks.

**Prioridade 2 — Redução da contenção**

Avaliar batching ou agregação assíncrona dos incrementos, desde que os requisitos de consistência e atualização imediata do contador permitam.

**Prioridade 3 — Gerenciamento de conexões**

Avaliar connection pooling e medir sua contribuição para latência e utilização de recursos.

**Prioridade 4 — Logging estruturado**

Definir políticas de logging adequadas à operação, preservando erros e informações necessárias para investigação.

## 9. Resultado final

A investigação permitiu identificar um padrão de contenção concorrente, realizar melhorias pontuais e validar a continuidade funcional da aplicação.

As alterações não demonstraram eliminação do gargalo arquitetural nem ganho de desempenho conclusivo.

**Estado final:** serviço funcional; investigação concluída; otimização estrutural pendente.

## 10. Lições aprendidas

- Aumentar recursos computacionais não elimina necessariamente dependências de serialização.
- Status HTTP 200 não é evidência suficiente de desempenho adequado.
- Correlação entre CPU, banco de dados e latência é essencial para formular hipóteses.
- Alterações precisam ser avaliadas por medições comparáveis.
- Um relatório técnico deve distinguir claramente o que foi observado, inferido e comprovado.