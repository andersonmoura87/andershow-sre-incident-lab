# INC-003 — Tokamachi: controle de fluxo em named pipe

**Ambiente:** SadServers — Debian 13, simulado, sem acesso sudo
**Classificação:** Laboratório de troubleshooting / Linux IPC
**Status:** Resolvido e validado pelo checker oficial
**Tempo de resolução:** 6min04s
**Dicas utilizadas:** 0
**Pontuação:** 1

## 1. Resumo executivo

O cenário apresentava interrupções ou atrasos no processamento de mensagens transmitidas por um named pipe (FIFO).

A investigação identificou um processo leitor ativo, configurado com uma pausa de dois segundos entre tentativas de leitura. O comando escritor originalmente proposto pelo cenário enviava mensagens continuamente, sem intervalo explícito.

A intervenção consistiu em executar um produtor com intervalo de três segundos entre escritas, permitindo que o consumidor acompanhasse o fluxo de mensagens nas condições testadas.

A validação demonstrou recebimento contínuo no arquivo de log, retorno `OK` no script de verificação e aprovação pelo checker oficial do SadServers.

## 2. Objetivo e critérios de sucesso

Restabelecer o fluxo contínuo de mensagens entre o processo escritor e o leitor por meio de `/home/admin/namedpipe`.

**Critérios de sucesso:**

- Manter um processo escritor ativo.
- Introduzir um intervalo entre escritas.
- Confirmar recebimento contínuo em `/home/admin/reader.log`.
- Obter aprovação no mecanismo oficial de validação.

## 3. Ambiente e componentes

| Componente | Descrição |
|---|---|
| Sistema operacional | Debian 13 |
| Mecanismo IPC | Named pipe (FIFO) |
| FIFO | `/home/admin/namedpipe` |
| Processo leitor | `/home/admin/start_reader.sh` |
| Arquivo de log | `/home/admin/reader.log` |
| Processo escritor | Bash executado em segundo plano |
| Permissões | Usuário `admin`, sem sudo |

O named pipe permite comunicação entre processos por meio de um fluxo de bytes. Sua capacidade de buffering é limitada, e operações de escrita podem bloquear quando não há capacidade suficiente para aceitar mais dados.

## 4. Diagnóstico e evidências

### 4.1 Identificação da FIFO

Comando executado:

```bash
ls -l /home/admin/namedpipe
```

Resultado observado:

```text
prw-r--r-- 1 admin admin 0 Aug 11 02:28 /home/admin/namedpipe
```

O primeiro caractere `p` confirmou que o arquivo era uma FIFO.

### 4.2 Identificação do consumidor

Comando executado:

```bash
ps aux | grep -E '[r]eader|[n]amedpipe'
```

Foi identificado o processo:

```text
/bin/bash /home/admin/start_reader.sh
```

PID observado: `855`.

O processo leitor estava em execução no momento da inspeção.

### 4.3 Análise do comportamento do leitor

A inspeção do script mostrou que o consumidor:

- Abre a FIFO por meio do descritor de arquivo 3.
- Executa tentativas de leitura em loop.
- Registra mensagens recebidas com timestamp.
- Reabre o pipe quando necessário.
- Executa `sleep 2` entre iterações.

Esse intervalo impõe uma limitação deliberada à cadência de processamento do consumidor.

### 4.4 Hipótese operacional

O escritor original executava um loop sem pausa explícita entre as mensagens.

**Hipótese:** a diferença entre a velocidade de produção e a cadência do consumidor poderia provocar bloqueio do escritor e atrasos no processamento.

A hipótese é compatível com o comportamento de uma FIFO e com a configuração observada. Entretanto, não foram coletadas métricas de ocupação do buffer ou rastreamentos de chamadas de sistema para confirmar diretamente o mecanismo de bloqueio.

## 5. Remediação

Foi iniciado um processo escritor em segundo plano com intervalo de três segundos:

```bash
/bin/bash -c 'while true; do echo "INC-003 test message" > /home/admin/namedpipe; sleep 3; done' &
```

**Justificativa técnica:** limitar a cadência de envio para que o consumidor consiga acompanhar o fluxo nas condições do laboratório.

A alteração foi realizada no comportamento do produtor, sem modificar o script leitor ou recriar a FIFO.

## 6. Validação

### 6.1 Observação do recebimento

Comando:

```bash
tail -f /home/admin/reader.log
```

O log apresentou 26 mensagens consecutivas entre 00:51:44 e 00:52:59 UTC, com intervalos de aproximadamente três segundos.

Não foram observadas interrupções prolongadas durante essa janela.

### 6.2 Validação automatizada

Comando:

```bash
/home/admin/agent/check.sh
```

Resultado:

```text
OK
```

### 6.3 Confirmação oficial

O checker do SadServers confirmou a solução correta.

| Indicador | Resultado |
|---|---|
| Solução | Aprovada |
| Tempo | 6min04s |
| Dicas | 0 |
| Pontuação | 1 |

**Conclusão da validação:** os critérios do cenário foram atendidos. O fluxo permaneceu funcional durante a observação registrada.

## 7. Causa provável e fatores contribuintes

**Observações confirmadas:**

- A FIFO existia.
- O leitor estava em execução.
- O leitor possuía uma pausa de dois segundos.
- O comando escritor original não possuía pausa explícita.
- O produtor com intervalo de três segundos manteve o recebimento contínuo durante o teste.
- O checker oficial aprovou a solução.

**Causa provável:** incompatibilidade entre a taxa de produção de mensagens e a cadência de consumo.

**Não determinado:** o ponto exato de saturação, a capacidade efetiva do buffer durante o incidente e a duração dos bloqueios de escrita.

## 8. Riscos, rollback e limitações

A intervenção é simples e reversível: o processo escritor iniciado em segundo plano pode ser encerrado, restaurando a condição anterior do produtor.

A escolha de `sleep 3` foi adequada ao laboratório, mas não constitui uma solução universal de controle de fluxo.

Limitações identificadas:

- Não houve teste de carga progressivo.
- Não foi mensurada a capacidade máxima de processamento.
- Não foram implementados mecanismos de persistência ou confirmação de entrega.
- Não houve medição de latência por mensagem.
- A observação contínua não demonstra ausência de perdas em cenários diferentes.

## 9. Lições aprendidas e ações preventivas

1. A existência de um processo não garante sua capacidade de acompanhar a carga recebida.
2. Named pipes podem aplicar backpressure quando a leitura não acompanha a escrita.
3. O ritmo de produção deve considerar a capacidade do consumidor.
4. A validação deve incluir comportamento observado, não apenas o estado dos processos.
5. Em sistemas de produção, avaliar mecanismos apropriados de buffering, filas, observabilidade e tratamento de falhas conforme os requisitos de entrega.

## 10. Evidências e referências

**Evidências coletadas:** inspeção da FIFO, identificação do processo leitor, análise do script, registros do `reader.log`, retorno do `check.sh` e confirmação visual do checker.

Capturas revisadas poderão ser adicionadas ao diretório `evidence/`.

**Referência:** SadServers — cenário *Tokamachi: Troubleshooting a Named Pipe*.

**Escopo:** incidente simulado para aprendizado. Não representa uma ocorrência real de produção.
