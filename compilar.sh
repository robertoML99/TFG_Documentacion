#!/usr/bin/env bash
set -u

MAIN="tfgtfmthesisuam"
TEXFILE="${MAIN}.tex"
PDF="${MAIN}.pdf"

red()    { printf '\033[0;31m%s\033[0m\n' "$1"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[1;33m%s\033[0m\n' "$1"; }

fail() {
  red "ERROR: $1"
  exit 1
}

warn() {
  yellow "AVISO: $1"
}

run_pdflatex() {
  yellow "==> Ejecutando pdflatex sobre ${TEXFILE}"
  pdflatex -interaction=nonstopmode -file-line-error "$TEXFILE"
  local status=$?

  if [[ -f "$PDF" ]]; then
    if [[ $status -ne 0 ]]; then
      warn "pdflatex devolvió código $status, pero el PDF sí existe. Continúo."
    fi
    return 0
  fi

  return $status
}

run_bibtex_if_needed() {
  if [[ ! -f "${MAIN}.aux" ]]; then
    yellow "No existe ${MAIN}.aux todavía; se omite bibtex."
    return 0
  fi

  if grep -Eq '\\bibdata|\\citation|\\bibstyle' "${MAIN}.aux"; then
    yellow "==> Detectada bibliografía/citas; ejecutando bibtex"
    bibtex "${MAIN}"
    local status=$?

    if [[ $status -ne 0 ]]; then
      if grep -q "I found no \\\\citation commands" "${MAIN}.blg" 2>/dev/null; then
        warn "BibTeX no encuentra citas reales; se omite."
        return 0
      fi
      return $status
    fi
  else
    yellow "==> No hay citas/bibliografía activas; se omite bibtex"
  fi

  return 0
}

clean_aux() {
  yellow "==> Limpiando archivos auxiliares antiguos"
  rm -f \
    "${MAIN}.aux" "${MAIN}.bbl" "${MAIN}.bcf" "${MAIN}.blg" \
    "${MAIN}.fdb_latexmk" "${MAIN}.fls" "${MAIN}.glg" "${MAIN}.glo" \
    "${MAIN}.gls" "${MAIN}.idx" "${MAIN}.ilg" "${MAIN}.ind" \
    "${MAIN}.lof" "${MAIN}.log" "${MAIN}.lot" "${MAIN}.out" \
    "${MAIN}.run.xml" "${MAIN}.synctex.gz" "${MAIN}.toc" \
    "${MAIN}.acn" "${MAIN}.acr" "${MAIN}.alg" \
    "${MAIN}.nav" "${MAIN}.snm" "${MAIN}.vrb" "${MAIN}.xdv" \
    "${MAIN}.mw"
}

[[ -f "$TEXFILE" ]] || fail "No encuentro ${TEXFILE}. Ejecuta el script desde la raíz del proyecto."

clean_aux

run_pdflatex || fail "Falló la primera pasada de pdflatex y no se generó PDF."
run_bibtex_if_needed || fail "Falló bibtex. Revisa ${MAIN}.blg."
run_pdflatex || fail "Falló la segunda pasada de pdflatex y no se generó PDF."
run_pdflatex || fail "Falló la tercera pasada de pdflatex y no se generó PDF."

if [[ -f "$PDF" ]]; then
  green "Compilación completada correctamente: ${PDF}"
  exit 0
else
  fail "No se generó el PDF."
fi
