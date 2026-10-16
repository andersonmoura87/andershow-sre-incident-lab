# INC-003 — Tokamachi: backpressure em named pipe

**Ambiente:** SadServers, Debian 13, simulado, sem sudo  
**Status:** resolvido e validado oficialmente  
**Tempo:** 6min04s | **Dicas:** 0 | **Pontuação:** 1

## Objetivo
Manter um escritor enviando mensagens a `/home/admin/namedpipe` com intervalo entre escritas e confirmar recebimento contínuo em `/home/admin/reader.log`.

## Diagnóstico e evidências
1. `ls -l /home/admin/namedpipe` mostrou `prw-r--r--`, confirmando FIFO.
2. `ps aux | grep -E '[r]eader|[n]amedpipe'` mostrou `/bin/bash /home/admin/start_reader.sh` (PID 855 na observação).
3. Inspeção do leitor revelou `sleep 2` entre tentativas de leitura, limitando a cadência.
4. Hipótese: produtor sem pausa pode superar o ritmo do consumidor, levando a backpressure.

## Remediação
Produtor iniciado em segundo plano com intervalo de 3 segundos:

```bash
/bin/bash -c 'while true; do echo "INC-003 test message" > /home/admin/namedpipe; sleep 3; done' &
```

## Validação
- `tail -f /home/admin/reader.log` mostrou 26 mensagens consecutivas entre 00:51:44 e 00:52:59 UTC, a cada 3 segundos.
- `/home/admin/agent/check.sh` retornou `OK`.
- Interface do SadServers confirmou solução correta, 6min04s, 0 dicas e 1 ponto.

## Causa e limitações
**Causa provável sustentada pelo experimento:** descompasso entre taxa de escrita e leitura. O teste comprova que o rate limiting satisfaz o cenário; não mede a capacidade máxima da FIFO nem garante escalabilidade. `sleep 3` é uma mitigação de laboratório, não substitui projeto de filas/controle de fluxo em produção.

## Evidências visuais
Capturas originais podem ser adicionadas em `evidence/` após revisão de dados sensíveis.
