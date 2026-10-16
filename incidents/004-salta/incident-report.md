# INC-004 — Salta: Falha na inicialização de aplicação Node.js em Docker

## Resumo executivo

**Ambiente:** SadServers — Salta, Debian 13, laboratório simulado e efêmero.

**Dificuldade:** Medium.

**Status:** Resolvido — checker oficial aprovado.

**Severidade:** Não atribuída; ambiente educacional sem impacto de produção.

Uma aplicação Node.js containerizada não estava disponível na porta 8888 do host. A investigação identificou um comando de inicialização incorreto na imagem Docker e a ocupação da porta 8888 pelo nginx do host.

A correção envolveu reconstruir a imagem com o comando adequado, interromper o serviço conflitante e publicar a aplicação utilizando o mapeamento de portas do Docker.

## Objetivo e critérios de sucesso

O cenário exigia:

- Aplicação HTTP respondendo exatamente `Hello World!` em `localhost:8888`.
- Apenas um container Docker em execução.
- Porta 8888 do host publicada pelo container.
- Aprovação do checker oficial SadServers.

## Linha do tempo (UTC)

A sequência abaixo é relativa. Não foram preservados horários absolutos para todas as ações.

| Etapa | Evento |
|---|---|
| T1 | Identificação do container `app` em estado `Exited (1)` |
| T2 | Verificação de que `localhost:8888` retornava a página padrão do nginx |
| T3 | Análise dos logs: arquivo `serve.js` não encontrado |
| T4 | Inspeção do Dockerfile e identificação do arquivo existente `server.js` |
| T5 | Correção do comando de inicialização e build da imagem `app:fixed` |
| T6 | Inicialização isolada do container `salta-test` |
| T7 | Confirmação de execução do Node.js por meio dos logs |
| T8 | Investigação das permissões e do serviço nginx |
| T9 | Remediação final e validação pelo checker oficial |

## Sintomas e impacto observado

O container original apresentava estado `Exited (1)`.

A requisição HTTP para `localhost:8888` retornava status 200, porém com a página padrão do nginx, e não a resposta esperada da aplicação.

Isso demonstrava que a disponibilidade da porta HTTP não significava disponibilidade do serviço correto.

## Evidências

| Evidência | Comando ou fonte | Observação | Limitação |
|---|---|---|---|
| Container encerrado | `docker ps -a` | `app` em `Exited (1)` | Estado observado no início da investigação |
| Erro de inicialização | `docker logs --tail 50 app` | `MODULE_NOT_FOUND` para `/usr/src/app/serve.js` | Explica a falha original de inicialização |
| Configuração da imagem | `cat Dockerfile` | `CMD ["node", "serve.js"]` | Comando incompatível com o arquivo existente |
| Código da aplicação | `cat server.js` | Aplicação Express configurada para usar a porta 8888 por padrão | Inspeção estática |
| Serviço HTTP incorreto | `curl -i localhost:8888` | Resposta HTTP 200 com página padrão do nginx | Não representava a aplicação Node.js |
| Porta ocupada | `ss -ltnp` | Porta 8888 em estado LISTEN | A primeira inspeção não identificou o PID responsável |
| nginx ativo | `systemctl status nginx` | Serviço ativo, com processo principal executado por root | Evidência adicional do serviço no host |
| Imagem corrigida | `docker build -t app:fixed .` | Build concluído | Build bem-sucedido não comprova execução |
| Comando corrigido | `docker image inspect app:fixed` | `["node","server.js"]` | Confirma configuração da imagem |
| Inicialização isolada | `docker ps -a` e `docker logs salta-test` | Container em execução; log `Server Started on: 8888` | Não comprova, isoladamente, resposta HTTP externa |
| Permissões | `sudo -n -l` | Autorização `NOPASSWD: ALL` observada | Configuração específica desta VM |
| Validação oficial | SadServers — Check My Solution | `Solution is correct` | Confirma critérios do exercício |

## Hipóteses e testes

**Hipótese 1 — O container encerrava por erro no comando de inicialização.**

Confirmada pelo erro `MODULE_NOT_FOUND`, pelo Dockerfile e pela existência de `server.js`.

**Hipótese 2 — A aplicação apresentava falha de dependências.**

Não confirmada. Após a correção do comando, o container de teste permaneceu em execução e registrou a inicialização do servidor.

**Hipótese 3 — Outro serviço ocupava a porta exigida pelo laboratório.**

Sustentada pela resposta HTTP do nginx, pela porta 8888 em estado LISTEN e pelo estado ativo do serviço.

## Causa raiz e fatores contribuintes

**Confirmado:**

- O Dockerfile utilizava `serve.js`, mas o arquivo da aplicação era `server.js`.
- O container original encerrava com código 1.
- O nginx atendia requisições na porta 8888 do host.
- A imagem corrigida permitiu iniciar o servidor Node.js.

**Fator contribuinte:**

O Dockerfile declarava `EXPOSE 8880`, enquanto a aplicação utilizava 8888 por padrão. Essa inconsistência dificultava a compreensão da configuração, mas não impedia o mapeamento explícito de portas.

**Não determinado:**

A origem das configurações incorretas e o histórico anterior à execução do laboratório.

## Remediação e rollback

### Remediação

1. Corrigido o comando do Dockerfile de `serve.js` para `server.js`.
2. Construída a imagem `app:fixed`.
3. Testada a inicialização em container temporário sem publicação de porta.
4. Identificado o nginx como serviço desnecessário no cenário.
5. Utilizada a autorização administrativa disponível para interromper o nginx.
6. Substituído o container temporário por uma instância com publicação `8888:8888`.

### Rollback possível

Em um ambiente persistente, a reversão poderia envolver remover o container corrigido, restaurar a configuração anterior e reativar o nginx, após avaliação das dependências.

O rollback não foi executado, pois o laboratório era efêmero e foi encerrado após a validação.

## Validação antes/depois

| Critério | Antes | Depois |
|---|---|---|
| Inicialização da aplicação | Container `Exited (1)` | Container de teste iniciado com sucesso |
| Comando da imagem | `node serve.js` | `node server.js` |
| Porta HTTP do host | Resposta do nginx | Critérios oficiais do exercício aprovados |
| Checker SadServers | Não aprovado inicialmente | Aprovado |

**Resultado oficial:**

- Solução correta.
- Tempo de resolução: **9 minutos e 42 segundos**.
- Dicas utilizadas: **0**.
- Pontuação: **2 pontos**.

A saída detalhada dos comandos finais de publicação e do `curl` não foi preservada na conversa. A aprovação oficial constitui a evidência disponível de que os critérios finais foram atendidos.

## Lições aprendidas e ações preventivas

- Um build Docker bem-sucedido não garante que a aplicação inicialize.
- Logs do container devem ser investigados antes de reconstruções ou mudanças arbitrárias.
- HTTP 200 não comprova que o serviço correto está respondendo.
- É necessário distinguir portas internas do container e portas publicadas no host.
- `EXPOSE` é metadado da imagem, não publicação automática de portas.
- Testar a aplicação isoladamente ajuda a separar falhas internas de conflitos com serviços do host.
- As permissões efetivas devem ser verificadas antes de concluir que uma intervenção administrativa é impossível.
- Em produção, interrupções de serviços exigem análise de impacto e plano de rollback.

## Referências

- SadServers — cenário Salta: Docker container won't start.
- Docker — documentação de Dockerfile, imagens e publicação de portas.
- Node.js — documentação de execução de aplicações.
- Metodologia interna do Andershow SRE Incident Lab.
