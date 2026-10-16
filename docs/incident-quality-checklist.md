# Checklist de qualidade — Relatórios de incidentes SRE

## Objetivo

Estabelecer critérios mínimos para documentação de incidentes simulados, garantindo clareza técnica, rastreabilidade, reprodutibilidade e transparência sobre limitações.

## 1. Contexto e escopo

- [ ] O ambiente e o cenário estão identificados.
- [ ] O objetivo e os critérios de sucesso estão explícitos.
- [ ] O relatório diferencia incidentes simulados de incidentes reais.
- [ ] A severidade não é atribuída sem evidências de impacto.

## 2. Investigação e evidências

- [ ] Os comandos relevantes estão documentados.
- [ ] As observações são separadas das interpretações.
- [ ] Evidências de diferentes instâncias não são misturadas.
- [ ] Identificadores efêmeros, como PIDs, possuem contexto.
- [ ] Lacunas e limitações das evidências estão declaradas.

## 3. Diagnóstico

- [ ] As hipóteses estão claramente identificadas.
- [ ] A causa raiz é classificada como confirmada, inferida ou não determinada.
- [ ] Não existem conclusões mais fortes que as evidências disponíveis.
- [ ] Fatores contribuintes são diferenciados da causa principal.

## 4. Remediação

- [ ] A intervenção executada está registrada.
- [ ] O risco operacional da intervenção foi considerado.
- [ ] O rollback ou a impossibilidade de reversão está documentado.
- [ ] Recomendações futuras não são apresentadas como ações já executadas.

## 5. Validação

- [ ] Existe um critério verificável de sucesso.
- [ ] O resultado da validação está documentado.
- [ ] A validação oficial é diferenciada de verificações independentes.
- [ ] Comparações antes/depois utilizam evidências realmente coletadas.
- [ ] Resultados inconclusivos são declarados como tal.

## 6. Comunicação e segurança

- [ ] O resumo executivo permite compreender o caso sem ler todos os comandos.
- [ ] O relatório contém lições aprendidas.
- [ ] Evidências publicadas não expõem segredos ou informações sensíveis.
- [ ] Referências e caminhos relativos são válidos.
- [ ] O documento está formatado corretamente em Markdown.

## Critério de aprovação

Um relatório pode ser aprovado mesmo com evidências incompletas, desde que as limitações sejam explícitas e não existam conclusões sem sustentação.

A qualidade documental não depende de afirmar que todos os problemas foram resolvidos, mas de demonstrar corretamente o que foi investigado, observado, modificado e validado.
