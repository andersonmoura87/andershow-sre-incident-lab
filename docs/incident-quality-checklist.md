# Checklist de qualidade — Relatórios de incidentes SRE

## Objetivo

Estabelecer critérios mínimos para documentação de incidentes simulados, garantindo clareza técnica, rastreabilidade, reprodutibilidade e transparência sobre limitações.

O tamanho do relatório acompanha a complexidade do caso. Seção condicional sem fato correspondente não precisa ser preenchida com texto artificial.

Relatórios INC-001 a INC-007 permanecem no formato em que foram publicados. Relatório novo usa o modelo v2 e começa com `<!-- template: v2 -->` na primeira linha.

## 1. Contexto e escopo

- [ ] O ambiente e o cenário estão identificados.
- [ ] O objetivo e os critérios de sucesso estão explícitos.
- [ ] O relatório diferencia incidentes simulados de incidentes reais.
- [ ] A severidade não é atribuída sem evidências de impacto.

## 2. Investigação e evidências

- [ ] Os comandos relevantes estão documentados.
- [ ] As observações são separadas das interpretações.
- [ ] Há rastreio entre sintoma, hipótese, teste, decisão e resultado.
- [ ] Evidências de diferentes instâncias não são misturadas.
- [ ] Identificadores efêmeros, como PIDs, possuem contexto.
- [ ] Lacunas e limitações das evidências estão declaradas.
- [ ] Horário absoluto só aparece quando foi coletado.

## 3. Diagnóstico

- [ ] As hipóteses estão claramente identificadas.
- [ ] Cada conclusão usa um rótulo sustentado pela evidência: observado, confirmado, inferido, não determinado, proposto ou executado e validado.
- [ ] A causa raiz pode permanecer não determinada. Causa confirmada só aparece quando as evidências a sustentam.
- [ ] Não existem conclusões mais fortes que as evidências disponíveis.
- [ ] Fatores contribuintes são diferenciados da causa principal.

## 4. Decisões

- [ ] Intervenção, mudança relevante de direção diagnóstica ou aceitação de risco possui registro de decisão.
- [ ] O registro contém evidência, justificativa, risco ou trade-off e resultado observado.
- [ ] Teste trivial não ganhou uma linha artificial.
- [ ] Alternativa que não foi considerada não foi inventada.

## 5. Remediação

- [ ] A intervenção executada está registrada, ou a ausência de intervenção está declarada.
- [ ] O risco operacional da intervenção foi considerado.
- [ ] O rollback, ou a impossibilidade de reversão, está documentado.
- [ ] Riscos residuais depois da validação estão visíveis.
- [ ] Recomendações futuras não são apresentadas como ações já executadas.

## 6. Validação

- [ ] Existe um critério verificável de sucesso, ou a impossibilidade de medi-lo está declarada.
- [ ] O resultado da validação está documentado, com estado inicial e resultado posterior quando ambos foram coletados.
- [ ] A validação oficial é diferenciada de verificações independentes.
- [ ] Comparações antes/depois utilizam evidências realmente coletadas.
- [ ] Resultados inconclusivos ou não executados são declarados como tal.

## 7. Arquitetura e diagramas

- [ ] As-Is contém só arquitetura e falhas sustentadas por evidência.
- [ ] To-Be está marcado como proposta não implementada.
- [ ] Serviços, observabilidade ou controles não inspecionados não foram presumidos.
- [ ] Diagrama, quando existe, distingue relação observada de relação inferida e usa sintaxe Mermaid legível no GitHub.
- [ ] A ausência de diagrama é aceitável quando tabelas e texto já mostram o caso.

## 8. Comunicação e segurança

- [ ] O resumo executivo permite compreender o caso sem ler todos os comandos.
- [ ] O relatório contém lições aprendidas.
- [ ] Evidências publicadas não expõem segredos ou informações sensíveis.
- [ ] Referências e caminhos relativos são válidos.
- [ ] O relatório novo está no README e no catálogo técnico.
- [ ] O documento está formatado corretamente em Markdown.

## Critério de aprovação

Um relatório pode ser aprovado mesmo com evidências incompletas, desde que as limitações sejam explícitas e não existam conclusões sem sustentação.

A qualidade documental não depende de afirmar que todos os problemas foram resolvidos, mas de demonstrar corretamente o que foi investigado, observado, modificado e validado.
