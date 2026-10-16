# INC-002 — Linux Server Review: investigação de desempenho

**Ambiente:** SadServers, Debian 11, simulado  
**Status:** investigação concluída com melhorias pontuais; sem checker oficial  
**Objetivo:** caracterizar serviços, recursos e possíveis gargalos.

## Evidências selecionadas
- Aplicação Flask `webapp.py`, PostgreSQL, HAProxy e gerador de carga `wrk`.
- CPU observada quase saturada (`vmstat 1 6`: 0–1% ociosa em várias amostras).
- `pg_stat_activity` mostrou espera por `transactionid`; `pg_blocking_pids` identificou bloqueadores em uma amostra.
- A tabela `traffic` tinha uma linha; cada requisição fazia `UPDATE traffic SET counter = counter + 1`.
- `wrk -t2 -c50 -d15s`: baseline ~126,19 req/s e 390,54 ms de latência média; após refatoração ~130,13 req/s e 379,41 ms; após redução de logs ~130,81 req/s e 376,39 ms. Amostras curtas, não suficientes para comprovar ganho estatístico.
- Um evento histórico de OOM matou um processo `stress`.

## Intervenções
- Refatoração do handler para `UPDATE ... RETURNING counter`, transação com context manager e tratamento de erro HTTP 500.
- Redução de logs de acesso do Werkzeug para nível ERROR.
- Serviço reiniciado; `curl` retornou HTTP 200 e contador.

## Conclusões e limites
A contenção sobre um contador compartilhado é sustentada por código e observações de locks. Não está demonstrado que o consumo de CPU do Python tenha uma causa única, nem que as mudanças eliminem a contenção. Não houve correção arquitetural do hot row, nem checker oficial neste cenário. Evitar afirmar resolução integral.
