# Andershow SRE Incident Lab

Laboratório público de investigação e recuperação de incidentes simulados em Linux, aplicações e plataformas.

> **Escopo:** exercícios educacionais em ambientes efêmeros. Os resultados não representam incidentes reais de produção.

## Princípios

- Evidência antes de conclusão; distinguir observação, hipótese e causa confirmada.
- Mudanças mínimas, reversíveis e validadas.
- Não publicar segredos, IPs privados desnecessários ou dados pessoais.
- Relatórios em português; comandos e saídas preservados no idioma original.
- Métricas de desempenho apenas com contexto, carga e método de medição.

## Catálogo

| ID | Cenário | Situação | Validação |
|---|---|---|---|
| INC-001 | Saint John — processo escrevendo em log | Concluído | Checker do laboratório; pós-verificação independente não registrada |
| INC-002 | Linux Server Review — desempenho e banco | Investigação encerrada | Testes manuais; cenário sem checker oficial |
| INC-003 | Tokamachi — Named Pipe | Resolvido | `check.sh` retornou `OK`; 6min04s, 0 dicas |

## Navegação

- [Incidentes](incidents/)
- [Modelo de relatório](templates/incident-report.md)
- [Metodologia](docs/methodology.md)
- [Runbooks](runbooks/)

## Próximos passos

INC-004: troubleshooting Docker, selecionado após a publicação da primeira versão do repositório.
