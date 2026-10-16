# INC-001 — Saint John: escrita contínua em log

## Resumo executivo

**Ambiente:** SadServers — Debian 11, simulado
**Status:** Resolvido conforme checker oficial
**Severidade:** Não atribuída; impacto operacional não mensurado

O cenário consistia em interromper um processo Python que escrevia continuamente em `/var/log/bad.log`, preservando o arquivo. A investigação identificou o processo responsável, confirmou crescimento do log na primeira instância e realizou a interrupção na segunda instância. O checker oficial confirmou o sucesso da solução.

## Objetivo e critérios de sucesso

- Identificar o processo responsável pela escrita contínua.
- Interromper sua execução sem excluir `/var/log/bad.log`.
- Validar que a condição exigida pelo laboratório foi atendida.

## Linha do tempo e evidências

Os horários absolutos não foram preservados. A sequência abaixo representa a ordem dos eventos, não uma cronologia com timestamps verificáveis.

| Etapa | Evidência | Observação |
|---|---|---|
| 1 | Inspeção de processos | Identificado `/home/admin/badlog.py`, PID 589, na primeira instância |
| 2 | Inspeção de descritores | Descritor 3 associado a `/var/log/bad.log` |
| 3 | Medição do arquivo | Crescimento de 76.315 para 77.071 bytes em cinco segundos |
| 4 | Reconexão ao laboratório | Primeira instância expirada; ambiente substituído |
| 5 | Nova inspeção | Processo identificado com PID 587 |
| 6 | Remediação | Executado `kill -9 587` |
| 7 | Validação oficial | Checker do SadServers confirmou sucesso |

## Diagnóstico

**Confirmado:** um processo Python estava associado à escrita contínua no arquivo de log.

**Inferido:** a execução contínua do processo explicava o crescimento observado do arquivo.

**Não determinado:** impacto sobre capacidade de armazenamento, duração anterior do problema e existência de mecanismo de reinicialização automática do processo.

A substituição da instância demonstrou que o PID não era um identificador persistente entre ambientes.

## Remediação e riscos

Na segunda instância, foi executado:

```bash
kill -9 587
```

O comando envia `SIGKILL`, encerrando o processo sem permitir tratamento normal do sinal ou limpeza pela aplicação.

Em um ambiente de produção, a abordagem preferencial seria verificar o PID atual, avaliar o serviço responsável e tentar inicialmente `SIGTERM`, quando apropriado.

**Rollback:** não houve procedimento de reversão registrado. O processo foi encerrado e não foi documentado um mecanismo seguro para reiniciá-lo.

## Validação

**Antes da intervenção:** crescimento de 756 bytes em cinco segundos, observado na primeira instância.

**Depois da intervenção:** checker oficial confirmou a resolução na segunda instância.

**Limitação:** não foi realizada medição independente do crescimento do log após a interrupção na segunda instância. Portanto, a confirmação de sucesso se baseia no checker oficial.

## Lições aprendidas

- PIDs são efêmeros e devem ser reconfirmados após reconexões ou reinicializações.
- Identificar descritores de arquivo ajuda a relacionar processos a recursos utilizados.
- `SIGKILL` deve ser empregado conscientemente devido à ausência de encerramento gracioso.
- A validação deve ser registrada no mesmo ambiente em que a intervenção ocorreu, sempre que possível.
- Evidências coletadas em instâncias distintas precisam permanecer claramente identificadas.

## Ações preventivas propostas

- Adotar uma sequência padrão de identificação, sinalização e validação de processos.
- Registrar medições antes e depois das intervenções.
- Verificar mecanismos de supervisão e reinicialização antes de encerrar serviços.

Estas ações são recomendações decorrentes do exercício, não mudanças implementadas no laboratório.
