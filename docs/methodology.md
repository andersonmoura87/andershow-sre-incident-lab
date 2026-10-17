# Metodologia de resposta a incidentes simulados

Esta metodologia vale para exercícios em ambiente efêmero. Ela não descreve um incidente real de produção.

As fases abaixo são adaptáveis. A investigação pode voltar a uma fase anterior quando um teste mudar a hipótese. Quando uma fase não se aplicar, o relatório registra a ausência em vez de inventar uma ação.

1. **Escopo:** definir objetivo, critério de sucesso, tempo e permissões do laboratório.
2. **Reprodução:** obter o sintoma com o comando ou o procedimento do cenário.
3. **Baseline:** registrar o estado inicial e o impacto observado. Sem medição de usuários ou de negócio, a severidade não é atribuída.
4. **Componentes:** identificar o que foi visto e as dependências usadas na investigação.
5. **Hipóteses:** listar explicações concorrentes.
6. **Testes discriminantes:** escolher a observação que separa uma hipótese da outra.
7. **Evidências:** registrar comando, saída relevante, interpretação e limitação.
8. **Decisões:** justificar intervenção, mudança relevante de direção ou aceitação de risco. Um teste trivial não vira decisão.
9. **Plano:** definir a menor mudança capaz de tratar a causa sustentada, e como revertê-la.
10. **Preservação:** copiar ou anotar o estado anterior quando a mudança puder apagar evidência ou configuração.
11. **Aplicação:** executar a mudança e verificar o efeito imediato.
12. **Validação:** conferir a camada alterada e, em seguida, o critério de sucesso de ponta a ponta. O checker oficial fica separado de verificações independentes.
13. **Encerramento:** declarar resultado, riscos residuais e aprendizados. Proposta futura não é implementação.

## Vocabulário de evidência

| Rótulo | Uso |
|---|---|
| Observado | Comando, saída ou estado registrado |
| Confirmado | Hipótese sustentada pela observação |
| Inferido | Leitura compatível com o que foi observado, sem medição direta |
| Não determinado | Dado ausente. Não é preenchido por suposição |
| Proposto | Recomendação que não foi executada |
| Executado e validado | Mudança feita e conferida por um resultado observado |

Uma investigação pode terminar sem causa confirmada. Nesse caso, a causa permanece não determinada.

Não confundir HTTP 200 com latência adequada. Não tratar correlação isolada como causa. Não usar horário absoluto quando ele não tiver sido coletado.
