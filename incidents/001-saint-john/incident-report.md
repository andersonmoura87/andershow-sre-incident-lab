# INC-001 — Saint John: escrita contínua em log

**Ambiente:** SadServers, Debian 11, simulado  
**Status:** concluído no checker oficial  
**Objetivo:** interromper processo que escreve em `/var/log/bad.log`, sem excluir o arquivo.

## Evidências
- Processo `/home/admin/badlog.py` identificado escrevendo no log (descritor 3).
- No primeiro ambiente, log cresceu de 76.315 para 77.071 bytes em cinco segundos (+756 bytes).
- A instância original expirou; o PID 589 não existia no segundo ambiente.
- Na segunda instância, o processo tinha PID 587; `kill -9 587` foi executado.
- O checker oficial confirmou sucesso.

## Causa e intervenção
Processo ativo gerando escrita contínua. A ação final foi SIGKILL no PID verificado da segunda instância.

## Limitações e lições
- Não há evidência registrada de tentativa de SIGTERM bem-sucedida na segunda instância.
- Não foi feita verificação independente do crescimento do log após a remediação na segunda instância.
- PIDs são efêmeros; sempre reconfirmar antes de enviar sinais.
