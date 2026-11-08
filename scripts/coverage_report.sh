#!/usr/bin/env bash
set -euo pipefail
flutter test --coverage
python3 - <<'PY'
rows, tl, th, cur, l, h = [], 0, 0, None, 0, 0
for line in open('coverage/lcov.info', encoding='utf-8'):
    line = line.strip()
    if line.startswith('SF:'):
        cur = line[3:]
    elif line.startswith('LF:'):
        l = int(line[3:])
    elif line.startswith('LH:'):
        h = int(line[3:])
    elif line == 'end_of_record':
        rows.append((cur, h, l)); tl += l; th += h
rows.sort()
pct = lambda a, b: f"{(100 * a / b) if b else 100:.1f}%"
out = ["# Test coverage", "",
       "Згенеровано командою `bash scripts/coverage_report.sh` (`flutter test --coverage`).", "",
       f"**Загальне покриття рядків: {pct(th, tl)}** ({th} з {tl})", "",
       "| Файл | Покрито | Усього | % |", "|---|---:|---:|---:|"]
out += [f"| `{f}` | {a} | {b} | {pct(a, b)} |" for f, a, b in rows]
open('docs/COVERAGE.md', 'w', encoding='utf-8').write("\n".join(out) + "\n")
print("Загальне покриття:", pct(th, tl))
PY
