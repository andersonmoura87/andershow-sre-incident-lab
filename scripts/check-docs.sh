#!/usr/bin/env bash
# Valida a documentação do Andershow SRE Incident Lab.
# Uso: bash scripts/check-docs.sh [raiz]
set -euo pipefail

if [ "$#" -ge 1 ]; then
  ROOT=$1
else
  ROOT=$(cd "$(dirname "$0")/.." && pwd)
fi

cd "$ROOT"

required=(
  README.md
  incidents/README.md
  templates/incident-report.md
  templates/incident-report-v1.md
  docs/methodology.md
  docs/incident-quality-checklist.md
)

for file in "${required[@]}"; do
  if [ ! -s "$file" ]; then
    echo "Arquivo obrigatório ausente ou vazio: $file"
    exit 1
  fi
done

legacy=(
  incidents/001-saint-john/incident-report.md
  incidents/002-linux-server-review/incident-report.md
  incidents/003-tokamachi/incident-report.md
  incidents/004-salta/incident-report.md
  incidents/005-manhattan/incident-report.md
  incidents/006-tokyo/incident-report.md
  incidents/007-sume/incident-report.md
)

is_legacy() {
  local rel=$1
  local item
  for item in "${legacy[@]}"; do
    if [ "$rel" = "$item" ]; then
      return 0
    fi
  done
  return 1
}

for file in "${legacy[@]}"; do
  if [ ! -s "$file" ]; then
    echo "Relatório legado ausente ou vazio: $file"
    exit 1
  fi
  echo "Relatório legado verificado: $file"
done

marker='<!-- template: v2 -->'
required_headings=(
  "## Resumo executivo"
  "## Escopo e critérios de sucesso"
  "## Contexto do sistema"
  "## Sequência cronológica da investigação"
  "## Hipóteses e evidências"
  "## Causa raiz e fatores contribuintes"
  "## Lições aprendidas e ações preventivas"
  "## Limitações"
  "## Referências"
)

shopt -s nullglob
reports=(incidents/*/incident-report.md)
if [ "${#reports[@]}" -eq 0 ]; then
  echo "Nenhum relatório encontrado em incidents/*/incident-report.md"
  exit 1
fi

for report in "${reports[@]}"; do
  rel=${report#./}
  if [ ! -s "$report" ]; then
    echo "Relatório ausente ou vazio: $rel"
    exit 1
  fi
  if is_legacy "$rel"; then
    continue
  fi
  first=$(head -n 1 "$report" | tr -d '\r')
  if [ "$first" != "$marker" ]; then
    echo "Relatório novo sem marcador v2 na primeira linha: $rel"
    exit 1
  fi
  for heading in "${required_headings[@]}"; do
    if ! grep -q -E "^${heading}[[:space:]]*$" "$report"; then
      echo "Seção obrigatória ausente em $rel: $heading"
      exit 1
    fi
  done
  echo "Relatório v2 verificado: $rel"
done

while IFS= read -r file; do
  while IFS= read -r url; do
    [ -z "$url" ] && continue
    case "$url" in
      http://*|https://*|mailto:*) continue ;;
    esac
    path=${url%%#*}
    [ -z "$path" ] && continue
    target=$(dirname "$file")/"$path"
    if [ ! -e "$target" ]; then
      echo "Link relativo quebrado: $file -> $url"
      exit 1
    fi
  done < <(grep -o -E '\[[^]]*\]\([^)]+\)' "$file" | sed -E 's/^\[[^]]*\]\(//; s/\)$//' || true)
done < <(find . -path './.git' -prune -o -name '*.md' -type f -print)

secret_re='AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
secret_found=0
while IFS= read -r file; do
  if grep -n -E "$secret_re" "$file"; then
    secret_found=1
  fi
done < <(find . -path './.git' -prune -o -name '*.md' -type f -print)
if [ "$secret_found" -eq 1 ]; then
  echo "Possível segredo detectado"
  exit 1
fi

echo "Documentação verificada"
