#!/usr/bin/env bash

# Reproduce the build portion of .github/workflows/deploy-pages.yml locally.
# The deployment step is intentionally excluded.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "${script_dir}/.." && pwd)"
cd "${project_root}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

require_font() {
  local font_name="$1"
  if ! fc-match "${font_name}" | grep -Fq "${font_name}"; then
    printf 'Missing required font: %s\n' "${font_name}" >&2
    exit 1
  fi
}

require_command quarto
require_command python3
require_command Rscript
require_command fc-match
require_command rsvg-convert

require_font "Noto Serif CJK SC"
require_font "Noto Sans CJK SC"
require_font "Noto Sans Mono CJK SC"

printf 'Quarto: %s\n' "$(quarto --version)"
printf 'Python: %s\n' "$(python3 --version 2>&1)"
printf 'R: %s\n' "$(Rscript --version 2>&1)"
printf 'SVG converter: %s\n' "$(rsvg-convert --version | head -n 1)"

if [[ -f renv.lock ]]; then
  printf '\nRestoring R packages from renv.lock...\n'
  Rscript -e \
    'if (!requireNamespace("renv", quietly = TRUE)) stop("Install the renv package first."); renv::restore(prompt = FALSE)'
fi

printf '\nBuilding HTML...\n'
quarto render --profile html --to html

printf '\nPreparing continuous PDF sources...\n'
python3 scripts/build_pdf_sources.py

printf '\nBuilding PDF...\n'
quarto render --profile pdf --to elegantbook-pdf

pdf_count=0
while IFS= read -r -d '' pdf_file; do
  cp "${pdf_file}" _book/
  printf 'Copied %s to _book/%s\n' "${pdf_file}" "$(basename "${pdf_file}")"
  pdf_count=$((pdf_count + 1))
done < <(find _book-pdf -maxdepth 1 -type f -name '*.pdf' -print0)

if [[ "${pdf_count}" -eq 0 ]]; then
  printf 'No PDF was produced in _book-pdf.\n' >&2
  exit 1
fi

printf '\nLocal GitHub-style build completed successfully.\n'
html_output="${project_root}/_book/index.html"
printf 'Website: %s\n' "${html_output}"
printf 'PDF directory: %s/_book-pdf\n' "${project_root}"

if [[ "${OPEN_BUILD_OUTPUT:-1}" != "0" ]]; then
  if command -v open >/dev/null 2>&1; then
    printf 'Opening the generated website...\n'
    open "${html_output}"
  elif command -v xdg-open >/dev/null 2>&1; then
    printf 'Opening the generated website...\n'
    xdg-open "${html_output}"
  else
    printf 'No supported browser-opening command was found; open the website path above manually.\n'
  fi
fi
