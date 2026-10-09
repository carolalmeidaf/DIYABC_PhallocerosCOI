#!/usr/bin/env bash
# Newly assembled from the supplied methods record, not the original run script.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
ABCRANGER=${ABCRANGER:-"$ROOT/bin/abcranger"}
if [[ "$ABCRANGER" != /* || ! -x "$ABCRANGER" ]]; then
  echo 'Set ABCRANGER to an absolute path to the recorded executable.' >&2
  exit 1
fi
for pop in pop1 pop2 pop3; do
  for name in headerRF.txt reftableRF.bin statobsRF.txt; do
    if [[ ! -s "$ROOT/$pop/$name" ]]; then
      echo "Missing or empty input: $ROOT/$pop/$name" >&2
      exit 1
    fi
  done
done
OUT="$ROOT/results/rerun"
mkdir -p "$ROOT/results"
if [[ -e "$OUT" ]]; then
  echo "Output already exists: $OUT. Archive it before a new run." >&2
  exit 1
fi
mkdir "$OUT"
"$ABCRANGER" --help > "$OUT/abcranger_help.txt" 2>&1
for pop in pop1 pop2 pop3; do
  mkdir "$OUT/$pop"
  (
    cd "$ROOT/$pop"
    for n in 20000 50000 100000; do
      prefix="$OUT/$pop/modelchoice_${n}"
      "$ABCRANGER" -h headerRF.txt -r reftableRF.bin -b statobsRF.txt \
        -o "$prefix" -n "$n" -t 1000 -j 4 -s 12345 \
        > "${prefix}.run.log" 2>&1
    done
    for parameter in N1 N2 N3; do
      prefix="$OUT/$pop/param_${parameter}"
      "$ABCRANGER" -h headerRF.txt -r reftableRF.bin -b statobsRF.txt \
        -o "$prefix" -n 100000 -t 1000 -j 4 -s 12345 \
        --parameter "$parameter" --chosenscen 2 --noob 15000 \
        > "${prefix}.run.log" 2>&1
    done
  )
done
echo "Completed ABC-RF reanalysis: $OUT"
